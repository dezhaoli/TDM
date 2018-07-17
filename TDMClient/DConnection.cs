using System;
namespace com.devin.debugger
{
    public  class DConnection
    {
        private static IConnection connector;
        public static void Initialize()
        {
            connector = new DConnectionDefault();
            Connect();
        }
        internal static String Address{
            set{
                connector.Address = value;
            }
        }
        internal static Boolean Connected{
            get{
                return connector.Connected;
            }
        }
        internal static void Send(String id,Object data,Boolean direct)
        {
            connector.Send(id, data, direct);
        }
        internal static void ProcessQueue()
        {
            connector.ProcessQueue();
        }
        internal static void Connect()
        {
            connector.Connect();
        }

    }
}
