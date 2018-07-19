using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TDMClient
{
    public class TranslationDebugger : MonoBehaviour
    {
        private static bool _enabled = false;


        private static bool _initialized = false;

        internal static readonly int VERSION = 24;

        // Use this for initialization
        void Start()
        {
            
            Initialize(gameObject);
        }

        // Update is called once per frame
        void Update()
        {

        }
        private void OnGUI()
        {
            GUI.Box(new Rect(10, 10, 100, 90), "TranslatioinDebugger");
            if(GUI.Button(new Rect(20, 40, 80, 20), "Send")){

                Log("hi,i'am devin.");
            }
        }
        private void OnDestroy()
        {
            
        }

        internal static void Initialize(GameObject baseObj , string local = ""){
            if (_initialized) return;
            _initialized = true;
            DCore.Base = baseObj;
            DCore.Initialize();


            DConnection.Initialize();
            DConnection.Address = "127.0.0.1";
            DConnection.Connect();

        }

        public static bool Enabled
        {
            get
            {
                return _enabled;
            }
            set
            {
                _enabled = value;
            }
        }
        public static void Trace(object caller, object @object, string persion = "" ,string label="",uint color=0, int depth =5)
        {
            if(_initialized && _enabled){
                DCore.Trace(caller,@object,persion,label,color,depth);
            }
        }
        public static void Log(params object[] args){
            if (_initialized && _enabled)
            {
                if (args.Length == 0)
                    return;
                var target = "Log";
                //try
                //{
                //    throw (new Error());
                //}
                //catch (e:Error) {
                //    var stack:String = e.getStackTrace();
                //    if (stack != null && stack != "")
                //    {
                //        stack = stack.split("\t").join("");
                //        var lines:Array = stack.split("\n");
                //        if (lines.length > 2)
                //        {
                //            lines.shift(); // Error
                //            lines.shift(); // TranslationDebugger
                //            var s:String = lines[0];
                //            s = s.substring(3, s.length);
                //            var bracketIndex:int = s.indexOf("[");
                //            var methodIndex:int = s.indexOf("/");
                //            if (bracketIndex == -1) bracketIndex = s.length;
                //            if (methodIndex == -1) methodIndex = bracketIndex;
                //            target = DUtils.parseType(s.substring(0, methodIndex));
                //            if (target == "<anonymous>")
                //            {
                //                target = "";
                //            }
                //            if (target == "")
                //            {
                //                target = "Log";
                //            }
                //        }
                //    }
                //}

                // Send
                if (args.Length == 1)
                {
                    DCore.Trace(target, args[0], "", "", 0x000000, 5);
                }
                else
                {
                    DCore.Trace(target, args, "", "", 0x000000, 5);
                }
            }
        }
    }
}