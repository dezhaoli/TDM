
using System;
using UnityEngine;

namespace TDMClient
{
    public class DCore
    {
        internal static GameObject Base;
        internal const string ID = "com.dezhaoli.debugger.core";

        public DCore()
        {
        }
        internal static void Initialize()
        {

        }
        public static void Trace(object caller, object obj, string persion = "", string label = "", uint color = 0, int depth = 5)
        {
            if (TranslationDebugger.Enabled)
            {
                string xml = DUtils.Parse(obj, "", 1, depth, false);
                TraceVO data = new TraceVO()
                {
                    command = DConstants.COMMAND_HELLO,
                    memory = DUtils.GetMemory(),
                    date = DateTime.Now,
                    reference = DUtils.getReferenceID(caller),
                    xml = xml,
                    persion = persion,
                    label = label,
                    color = color
                };
                Send(data);
            }
        }
        private static void Send(BaseVO data, bool direct = false)
        {
            if (TranslationDebugger.Enabled)
            {
                DConnection.Send(DCore.ID, data, direct);
            }
        }

        internal static void Handle(DData data)
        {
            throw new NotImplementedException();
        }
    }
}
