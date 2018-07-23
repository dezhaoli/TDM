
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
        /**
         * Send data to the desktop application.
         * @param data: The data to send
         * @param direct: Use the queue or send direct (handshake)
         */
        private static void Send(BaseVO data, bool direct = false)
        {
            if (TranslationDebugger.Enabled)
            {
                DConnection.Send(DCore.ID, data, direct);
            }
        }

        internal static void Handle(DData data)
        {
            if(TranslationDebugger.Enabled)
            {
                if (String.IsNullOrEmpty(data.Id))
                {
                    return;
                }
                HandleInternal(data);
            }


        }

        private static void HandleInternal(DData data)
        {
            switch (data.Id)
            {
                case DConstants.COMMAND_HELLO:
                    sendInformation();
                    break;
                default:
                    
                    break;
            }
        }

        private static void sendInformation()
        {
            
            //need to be accessed in the main thread,so move to TranslationDebugger' onstart
            //InfoVO data = new InfoVO()
            //{
            //    command = DConstants.COMMAND_INFO,
            //    debuggerVersion = TranslationDebugger.VERSION,
            //    playerType = UnityEngine.Application.platform.ToString(),
            //    playerVersion = TranslationDebugger.pv,
            //    isDebugger = Debug.isDebugBuild,
            //    fileLocation = "",
            //    fileTitle = UnityEngine.Application.productName,
            //    kvs = null
            //};

            // Send the data direct
            Send(TranslationDebugger.infoVO, true);

            // Start the queue after that
            DConnection.ProcessQueue();
        }
    }
}
