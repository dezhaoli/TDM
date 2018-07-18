using System;
namespace TDMClient
{
    internal interface IConnection
    {
        String Address { set; }
        Boolean Connected { get; }

        void Send(String id, BaseVO data, Boolean direct);
        void Connect();
        void ProcessQueue();

    }
}
