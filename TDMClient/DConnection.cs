using System;
namespace TDMClient
{
    public  class DConnection
    {
        private static IConnection connector;
        internal static void Initialize()
        {
            connector = new DConnectionDefault();
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
        internal static void Send(String id,BaseVO data,Boolean direct)
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
