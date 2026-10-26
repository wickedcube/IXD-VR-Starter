using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.SceneManagement;
using UnityEngine;
using Debug = UnityEngine.Debug;

/// <summary>
/// Point-and-click save/restore for students who are new to git.
/// Menu: Team/Save and Restore. Needs git installed (see setup/ folder).
/// </summary>
public class TeamSaveWindow : EditorWindow
{
    private const string AppIdPrefix = "com.ixd.";
    private const int HistoryCount = 30;
    private static readonly string[] ProjectFolders = { "Assets", "Packages", "ProjectSettings" };

    private struct SaveEntry
    {
        public string Id;
        public string When;
        public string Message;
    }

    private readonly List<SaveEntry> history = new List<SaveEntry>();
    private string message = "";
    private string status = "";
    private MessageType statusType = MessageType.None;
    private string pendingChanges = "";
    private string studentName = "";
    private string appTitle = "";
    private bool showSetup;
    private Vector2 scroll;
    private string gitPath;

    private static string ProjectRoot => Directory.GetParent(Application.dataPath).FullName;

    [MenuItem("Team/Save and Restore")]
    private static void Open() => GetWindow<TeamSaveWindow>("Save & Restore");

    private void OnEnable()
    {
        gitPath = FindGit();
        appTitle = PlayerSettings.productName;
        Refresh();
    }

    private void OnFocus() => Refresh();

    private void OnGUI()
    {
        if (gitPath == null)
        {
            EditorGUILayout.HelpBox(
                "Git is not installed (or Unity can't find it).\n\n" +
                "Run the setup script in the project's setup folder (Setup-Mac.command or Setup-Windows.bat), " +
                "then restart your computer and Unity.",
                MessageType.Error);
            if (GUILayout.Button("Check again")) { gitPath = FindGit(); Refresh(); }
            return;
        }

        if (!Directory.Exists(Path.Combine(ProjectRoot, ".git")))
        {
            EditorGUILayout.HelpBox(
                "This project isn't a git repository. Clone it with GitHub Desktop instead of downloading a zip.",
                MessageType.Warning);
            return;
        }

        scroll = EditorGUILayout.BeginScrollView(scroll);

        DrawSaveSection();
        EditorGUILayout.Space(12);
        DrawHistorySection();
        EditorGUILayout.Space(12);
        DrawSetupSection();

        EditorGUILayout.EndScrollView();
    }

    private void DrawSaveSection()
    {
        EditorGUILayout.LabelField("Save your work", EditorStyles.boldLabel);
        EditorGUILayout.LabelField(
            string.IsNullOrEmpty(pendingChanges) ? "No unsaved changes." : pendingChanges,
            EditorStyles.miniLabel);

        EditorGUILayout.LabelField("What did you change?");
        message = EditorGUILayout.TextField(message);

        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("Save", GUILayout.Height(28))) Save();
            if (GUILayout.Button("Open GitHub Desktop", GUILayout.Height(28))) OpenGitHubDesktop();
        }

        if (!string.IsNullOrEmpty(status))
        {
            EditorGUILayout.HelpBox(status, statusType);
        }
    }

    private void DrawHistorySection()
    {
        EditorGUILayout.LabelField("Earlier saves", EditorStyles.boldLabel);
        if (history.Count == 0)
        {
            EditorGUILayout.LabelField("Nothing saved yet.", EditorStyles.miniLabel);
            return;
        }

        foreach (var entry in history)
        {
            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
            {
                EditorGUILayout.LabelField(
                    new GUIContent($"{entry.Message}\n{entry.When}", entry.Id),
                    EditorStyles.wordWrappedLabel);
                if (GUILayout.Button("Restore", GUILayout.Width(64), GUILayout.Height(32)))
                {
                    Restore(entry);
                    GUIUtility.ExitGUI();
                }
            }
        }
    }

    private void DrawSetupSection()
    {
        showSetup = EditorGUILayout.Foldout(showSetup, "First-time setup: name your app", true);
        if (!showSetup) return;

        EditorGUILayout.HelpBox(
            "Every student needs a different app ID, or installing your build on a shared headset " +
            "replaces someone else's app. It is normally set for you from your GitHub account when you " +
            "open the project; use this only to choose your own.", MessageType.Info);
        EditorGUILayout.LabelField("Current app ID", PlayerSettings.GetApplicationIdentifier(NamedBuildTarget.Android));
        studentName = EditorGUILayout.TextField("Your name", studentName);
        appTitle = EditorGUILayout.TextField("App title", appTitle);

        var id = BuildAppId(studentName);
        EditorGUILayout.LabelField("App ID", id ?? "(enter your name)");

        using (new EditorGUI.DisabledScope(id == null))
        {
            if (GUILayout.Button("Apply"))
            {
                PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Android, id);
                PlayerSettings.SetApplicationIdentifier(NamedBuildTarget.Standalone, id);
                PlayerSettings.productName = string.IsNullOrWhiteSpace(appTitle) ? studentName : appTitle;
                AssetDatabase.SaveAssets();
                message = "Set up my project";
                SetStatus($"App ID set to {id}. Click Save to keep it.", MessageType.Info);
            }
        }
    }

    private static string BuildAppId(string name)
    {
        var segment = AppIdGuard.Segment(name);
        return segment == null ? null : AppIdPrefix + segment;
    }

    private void Save()
    {
        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
        AssetDatabase.SaveAssets();

        var text = string.IsNullOrWhiteSpace(message) ? $"Save {DateTime.Now:yyyy-MM-dd HH:mm}" : message.Trim();

        Git("add -A");
        if (Git("diff --cached --quiet").Code == 0)
        {
            SetStatus("Nothing new to save.", MessageType.Info);
            Refresh();
            return;
        }

        var commit = Git("commit -q -m", text);
        if (commit.Code != 0)
        {
            SetStatus("Save failed:\n" + commit.Output + "\nIf this mentions user.name or user.email, " +
                      "sign in to GitHub Desktop once, or ask your instructor.", MessageType.Error);
            return;
        }

        message = "";
        var push = Git("push -q -u origin HEAD");
        if (push.Code == 0)
        {
            SetStatus("Saved and uploaded to GitHub.", MessageType.Info);
        }
        else
        {
            SetStatus("Saved on your computer. To upload it, open GitHub Desktop and click \"Push origin\".",
                MessageType.Warning);
            OpenGitHubDesktop();
        }
        Refresh();
    }

    private void Restore(SaveEntry entry)
    {
        if (!EditorUtility.DisplayDialog(
                "Restore this save?",
                $"\"{entry.Message}\" ({entry.When})\n\nYour current work is saved first, so you can always come back to it.",
                "Restore", "Cancel"))
        {
            return;
        }

        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
        AssetDatabase.SaveAssets();

        Git("add -A");
        if (Git("diff --cached --quiet").Code != 0)
        {
            Git("commit -q -m", "Auto-save before restoring " + entry.Id);
        }

        var restore = Git("restore --source=" + entry.Id + " --staged --worktree --", ProjectFolders);
        if (restore.Code != 0)
        {
            SetStatus("Restore failed:\n" + restore.Output, MessageType.Error);
            return;
        }

        Git("add -A");
        Git("commit -q -m", "Restore project to " + entry.Id);
        AssetDatabase.Refresh();
        SetStatus($"Restored to \"{entry.Message}\".", MessageType.Info);
        Refresh();
    }

    private void Refresh()
    {
        history.Clear();
        pendingChanges = "";
        if (gitPath == null || !Directory.Exists(Path.Combine(ProjectRoot, ".git"))) return;

        var changes = Git("status --porcelain");
        if (changes.Code == 0)
        {
            var count = changes.Output.Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries).Length;
            pendingChanges = count == 0 ? "" : $"{count} changed file{(count == 1 ? "" : "s")} not saved yet.";
        }

        var log = Git($"log -n {HistoryCount} --date=format:%a-%d-%b-%H:%M --pretty=format:%h|%ad|%s");
        if (log.Code == 0)
        {
            foreach (var line in log.Output.Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries))
            {
                var parts = line.Trim().Split(new[] { '|' }, 3);
                if (parts.Length == 3)
                {
                    history.Add(new SaveEntry { Id = parts[0], When = parts[1].Replace('-', ' '), Message = parts[2] });
                }
            }
        }
        Repaint();
    }

    private void SetStatus(string text, MessageType type)
    {
        status = text;
        statusType = type;
        Repaint();
    }

    private static void OpenGitHubDesktop()
    {
        Application.OpenURL("x-github-client://openRepo/" + Uri.EscapeUriString(ProjectRoot.Replace('\\', '/')));
    }

    private struct GitResult
    {
        public int Code;
        public string Output;
    }

    // Arguments after the first string are passed as separate, already-quoted args
    // (used for commit messages and paths so spaces and quotes are safe).
    private GitResult Git(string args, params string[] extra)
    {
        var psi = new ProcessStartInfo(gitPath)
        {
            WorkingDirectory = ProjectRoot,
            UseShellExecute = false,
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
        };
        psi.EnvironmentVariables["GIT_TERMINAL_PROMPT"] = "0";
        psi.EnvironmentVariables["GCM_INTERACTIVE"] = "never";

        var sb = new StringBuilder(args);
        foreach (var a in extra)
        {
            sb.Append(' ').Append('"').Append(a.Replace("\"", "\\\"")).Append('"');
        }
        psi.Arguments = sb.ToString();

        try
        {
            using (var p = Process.Start(psi))
            {
                var output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
                if (!p.WaitForExit(120000))
                {
                    p.Kill();
                    return new GitResult { Code = -1, Output = "git timed out" };
                }
                return new GitResult { Code = p.ExitCode, Output = output.Trim() };
            }
        }
        catch (Exception e)
        {
            Debug.LogException(e);
            return new GitResult { Code = -1, Output = e.Message };
        }
    }

    private static string FindGit()
    {
        var candidates = new List<string>();
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            candidates.Add(@"C:\Program Files\Git\cmd\git.exe");
            candidates.Add(@"C:\Program Files (x86)\Git\cmd\git.exe");
            candidates.Add(Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                @"Programs\Git\cmd\git.exe"));
        }
        else
        {
            candidates.Add("/usr/bin/git");
            candidates.Add("/opt/homebrew/bin/git");
            candidates.Add("/usr/local/bin/git");
        }

        foreach (var c in candidates)
        {
            if (File.Exists(c)) return c;
        }

        var exe = Application.platform == RuntimePlatform.WindowsEditor ? "git.exe" : "git";
        foreach (var dir in (Environment.GetEnvironmentVariable("PATH") ?? "").Split(Path.PathSeparator))
        {
            try
            {
                var full = Path.Combine(dir, exe);
                if (File.Exists(full)) return full;
            }
            catch (ArgumentException)
            {
            }
        }
        return null;
    }
}
