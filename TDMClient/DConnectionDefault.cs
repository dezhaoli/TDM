using System;
using System.Net.Sockets;
using UnityEngine;

namespace TDMClient
{
    public class DConnectionDefault : IConnection
    {
        TcpClient _socket;
        string _ip = "127.0.0.1";
        public DConnectionDefault()
        {
            _socket = new TcpClient();
        }

        string IConnection.Address
        {
            set
            {
                _ip = value;
            }
        }

        bool IConnection.Connected{
            get
            {
                return _socket.Connected;
            }
        }

        void IConnection.Connect()
        {
            Debug.Log("BeginConnect!");
#if UNITY_EDITOR
            _socket.BeginConnect(_ip, 10086, HandleAsyncCallback, null);
#elif UNITY_ANDROID
            _socket.BeginConnect(_ip, 12580, HandleAsyncCallback, null);
#endif
        }

        void HandleAsyncCallback(IAsyncResult ar)
        {
            Debug.Log("Connected:"+ _socket.Connected);
            NetworkStream networkStream = _socket.GetStream();
            var bytes = System.Text.Encoding.UTF8.GetBytes("hello");
            networkStream.Write(bytes,0,bytes.Length);
            networkStream.Flush();
        }


        void IConnection.ProcessQueue()
        {
            throw new NotImplementedException();
        }

        void IConnection.Send(string id, BaseVO data, bool direct)
        {
            throw new NotImplementedException();
        }
    }
}
