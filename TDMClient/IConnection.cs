using System;
namespace com.devin.debugger
{
    internal interface IConnection
    {
        String Address { set; }
        Boolean Connected { get; }

        void Send(String id, Object data, Boolean direct);
        void Connect();
        void ProcessQueue();

    }
}
