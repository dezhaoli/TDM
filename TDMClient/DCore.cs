
using UnityEngine;

namespace TDM
{
    public class DCore
    {
        internal static GameObject Base;
        internal static readonly string ID = "com.dezhaoli.debugger.core";

        public DCore()
        {
        }
        internal static void Initialize()
        {

        }
        public static void Trace(object caller, object @object, string persion = "", string label = "", uint color = 0, int depth = 5)
        {
            if (TranslationDebugger.Enabled)
            {

            }
        }
        private static void Send(Object data, bool direct = false)
        {
            if (TranslationDebugger.Enabled)
            {
                DConnection.Send(DCore.ID, data, direct);
            }
        }
    }
}
