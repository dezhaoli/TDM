

outdir="bin/mcs"
rm -fr "$outdir"
mkdir "$outdir"
args=bin/mcs/build_args.txt
:>$args
#out
cat *.csproj | grep '<AssemblyName>' | sed 's@.*>\([^<]*\)<.*@-out:'"$outdir"'/\1.dll@' |tr \\ / >> $args
#lib
cat *.csproj | grep '<HintPath>' | sed 's/.*>\([^<]*\)<.*/-r:\1/' |tr \\ / >> $args
#def
cat *.csproj | grep '<DefineConstants>' | sed 's/.*>\([^<]*\)<.*/-define:\1/' |tr \\ / >> $args
#src
cat *.csproj | grep '<Compile Include=' | sed 's/.*"\([^"]*\)".*/\1/' |tr \\ / >> $args

/Library/Frameworks/Mono.framework/Versions/Current/Commands/mcs \
-target:library -debug -nowarn:0169 -langversion:4 -sdk:2.0 \
$(cat $args)
cp /Users/devin/WS/FlashProjects/TDM/TDMClient/bin/mcs/*dll* /Users/devin/Desktop/MyTestUnity/Assets/Plugin


# Filename: /Applications/Unity/Unity.app/Contents/MonoBleedingEdge/bin/mono
# Arguments: '/Applications/Unity/Unity.app/Contents/MonoBleedingEdge/lib/mono/4.5/mcs.exe'  @Temp/UnityTempFile-ad6d2e732cd2745d38c59e6b676c7bfe
# index: 81
# Responsefile: Temp/UnityTempFile-ad6d2e732cd2745d38c59e6b676c7bfe Contents: 
# -debug
# -target:library
# -nowarn:0169
# -langversion:4
# -out:'Temp/Assembly-CSharp.dll'
# -unsafe
# -r:'/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll'
# -r:'Library/ScriptAssemblies/Assembly-CSharp-firstpass.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/GUISystem/UnityEngine.UI.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/Networking/UnityEngine.Networking.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/TestRunner/UnityEngine.TestRunner.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/TestRunner/net35/unity-custom/nunit.framework.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/UnityAnalytics/UnityEngine.Analytics.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/UnityHoloLens/RuntimeEditor/UnityEngine.HoloLens.dll'
# -r:'/Applications/Unity/Unity.app/Contents/UnityExtensions/Unity/UnityVR/RuntimeEditor/UnityEngine.VR.dll'
# -r:'Assets/CSharpPlugins/AmplifyColor/CSPlugins/AmplifyColor.dll'
# -r:'Assets/Plugins/MoreFunMonoRuntime.dll'
# -r:'Assets/Plugins/ManagedLibs/Debuger.dll'
# -r:'Assets/Plugins/ManagedLibs/ICSharpCode.SharpZipLib.dll'
# -r:'Assets/Plugins/ManagedLibs/KHEngineBase.dll'
# -r:'Assets/Plugins/ManagedLibs/MarshalUtil.dll'
# -r:'Assets/Plugins/ManagedLibs/MiniJson.dll'
# -r:'Assets/Plugins/ManagedLibs/protobuf-net.dll'
# -r:'Assets/Plugins/Pandora_Managed/PandoraLogger.dll'
# -r:'Assets/Standard Assets/DOTween/DOTween.dll'
# -r:'Assets/Standard Assets/DOTween/DOTween43.dll'
# -r:'Assets/Standard Assets/DOTween/DOTween46.dll'
# -r:'Assets/Standard Assets/DOTween/DOTween50.dll'
# -r:'/Applications/Unity/Unity.app/Contents/Managed/UnityEditor.dll'
# -r:'/Applications/Unity/PlaybackEngines/iOSSupport/UnityEditor.iOS.Extensions.Xcode.dll'
# -r:'/Applications/Unity/PlaybackEngines/iOSSupport/UnityEditor.iOS.Extensions.Common.dll'
# -define:UNITY_5_3_OR_NEWER


