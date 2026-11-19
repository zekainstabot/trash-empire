using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public static class TrashEmpireBuild
{
    // Generates the entry scene in CI, then builds an Android APK.
    public static void BuildAndroid()
    {
        const string sceneDir = "Assets/TrashEmpire/Scenes";
        Directory.CreateDirectory(sceneDir);
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var root = new GameObject("Trash Empire Game");
        root.AddComponent<TrashEmpireGame>();
        const string scenePath = sceneDir + "/Main.unity";
        EditorSceneManager.SaveScene(scene, scenePath);
        AssetDatabase.SaveAssets();

        PlayerSettings.productName = "Trash Empire";
        PlayerSettings.companyName = "Zeka Games";
        PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.zekagames.trashempire");
        PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel23;
        PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
        PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
        PlayerSettings.Android.bundleVersionCode = 1;
        PlayerSettings.bundleVersion = "0.1.0";

        var options = new BuildPlayerOptions
        {
            scenes = new[] { scenePath },
            locationPathName = "Build/TrashEmpire.apk",
            target = BuildTarget.Android,
            options = BuildOptions.None
        };
        var report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
            throw new System.Exception("Android build failed: " + report.summary.result);
    }
}
