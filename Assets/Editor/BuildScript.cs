using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

/// <summary>
/// One-click and command-line Android (Meta Quest) builds.
/// Menu: Build/Quest/Build APK, Build/Quest/Build And Run.
/// CLI:  Unity -batchmode -quit -projectPath . -executeMethod BuildScript.BuildQuestApk [-output path.apk]
/// </summary>
public static class BuildScript
{
    private const string DefaultOutput = "Builds/IXDVRStarter.apk";

    [MenuItem("Build/Quest/Build APK")]
    public static void BuildQuestApk() => Build(run: false);

    [MenuItem("Build/Quest/Build And Run")]
    public static void BuildQuestAndRun() => Build(run: true);

    private static void Build(bool run)
    {
        var scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray();
        if (scenes.Length == 0)
        {
            throw new InvalidOperationException("No enabled scenes in Build Settings.");
        }

        var output = GetArg("-output") ?? DefaultOutput;
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output)));

        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
        }

        EditorUserBuildSettings.buildAppBundle = false;
        EditorUserBuildSettings.development = false;

        var options = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = output,
            target = BuildTarget.Android,
            options = run ? BuildOptions.AutoRunPlayer : BuildOptions.None,
        };

        var report = BuildPipeline.BuildPlayer(options);
        var summary = report.summary;
        Debug.Log($"Build {summary.result}: {summary.outputPath} ({summary.totalSize / (1024 * 1024)} MB)");

        if (summary.result != BuildResult.Succeeded && Application.isBatchMode)
        {
            EditorApplication.Exit(1);
        }
    }

    private static string GetArg(string name)
    {
        var args = Environment.GetCommandLineArgs();
        var i = Array.IndexOf(args, name);
        return i >= 0 && i + 1 < args.Length ? args[i + 1] : null;
    }
}
