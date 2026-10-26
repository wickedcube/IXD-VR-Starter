using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

/// <summary>
/// Gives every student's copy of the template a unique Android package name, derived from their
/// GitHub account and repo (com.ixd.&lt;owner&gt;.&lt;repo&gt;), so builds can share one headset
/// without overwriting each other. Also blocks builds that still use the template's package name.
/// </summary>
[InitializeOnLoad]
public class AppIdGuard : IPreprocessBuildWithReport
{
    public const string TemplateAppId = "com.ixd.vrstarter";
    private const string TemplateRepo = "wickedcube/ixd-vr-starter";
    private const string Prefix = "com.ixd.";

    public int callbackOrder => 0;

    static AppIdGuard()
    {
        EditorApplication.delayCall += () => TryAutoAssign();
    }

    /// <summary>Turns free text into a valid package-name segment, or null if nothing usable remains.</summary>
    public static string Segment(string text)
    {
        var sb = new StringBuilder();
        foreach (var c in (text ?? "").ToLowerInvariant())
        {
            if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) sb.Append(c);
        }
        if (sb.Length == 0) return null;
        if (char.IsDigit(sb[0])) sb.Insert(0, 'x');
        return sb.ToString();
    }

    private static bool TryReadRemote(out string owner, out string repo)
    {
        owner = repo = null;
        var config = Path.Combine(Directory.GetParent(Application.dataPath).FullName, ".git", "config");
        if (!File.Exists(config)) return false;

        foreach (var line in File.ReadAllLines(config))
        {
            var m = Regex.Match(line.Trim(), @"^url\s*=.*github\.com[:/]+([^/\s]+)/([^/\s]+?)(?:\.git)?$");
            if (m.Success)
            {
                owner = m.Groups[1].Value;
                repo = m.Groups[2].Value;
                return true;
            }
        }
        return false;
    }

    private static bool IsTemplateRepo(string owner, string repo) =>
        $"{owner}/{repo}".ToLowerInvariant() == TemplateRepo;

    private static string CurrentAppId() =>
        PlayerSettings.GetApplicationIdentifier(NamedBuildTarget.Android);

    /// <summary>If the package name is still the template's, replaces it with one unique to this student.</summary>
    public static bool TryAutoAssign()
    {
        if (CurrentAppId() != TemplateAppId) return false;
        if (!TryReadRemote(out var owner, out var repo) || IsTemplateRepo(owner, repo)) return false;

        var o = Segment(owner);
        var r = Segment(repo);
        if (o == null || r == null) return false;

        var id = $"{Prefix}{o}.{r}";
        PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Android, id);
        PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Standalone, id);
        AssetDatabase.SaveAssets();
        Debug.Log($"Package name set to {id} (from your GitHub repo). Click Save in Team > Save and Restore to keep it.");
        return true;
    }

    public void OnPreprocessBuild(BuildReport report)
    {
        if (report.summary.platform != BuildTarget.Android) return;
        if (CurrentAppId() != TemplateAppId) return;
        if (TryReadRemote(out var owner, out var repo) && IsTemplateRepo(owner, repo)) return;

        throw new BuildFailedException(
            $"The package name is still the template's ({TemplateAppId}). Students sharing a headset would overwrite " +
            "each other's apps. Open Team > Save and Restore > First-time setup and click Apply, then build again.");
    }
}
