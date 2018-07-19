using System;
using System.IO;
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
            DUtils.Log("BeginConnect!");
            StateObject so = new StateObject();
            so.client = _socket;
#if UNITY_EDITOR
            _socket.BeginConnect(_ip, 10086, OnConnect, so);
#elif UNITY_ANDROID
            _socket.BeginConnect(_ip, 12580, OnConnect, so);
#endif
        }

        void OnConnect(IAsyncResult ar)
        {
            StateObject state = (StateObject)ar.AsyncState;
            TcpClient tcp = state.client;
            DUtils.Log("TranslationDebugger Connected:"+ tcp.Connected);
            NetworkStream networkStream;

            try{
                tcp.EndConnect(ar);
                if (tcp.Connected)
                {
                    networkStream = tcp.GetStream();
                    if (networkStream.CanRead)
                    {
                        networkStream.BeginRead(state.buffer, 0, StateObject.BufferMaxSize, OnRead, state);
                        return;
                    }
                }
                closeSocket("Some error occur.Close nonnection...");
            }
            catch(Exception ex)
            {
                closeSocket("TranslationDebugger connection failed:" + ex.Message);
            }
            //var bytes = System.Text.Encoding.UTF8.GetBytes("hello");
            //networkStream.Write(bytes,0,bytes.Length);
            //networkStream.Flush();
        }

        void OnRead(IAsyncResult ar)
        {
            StateObject state = (StateObject)ar.AsyncState;
            TcpClient tcp = state.client;
            NetworkStream ns = tcp.GetStream();
            if(!tcp.Connected){
                closeSocket("TDC lost connection...");
                return;
            }
            state.bufferSize = ns.EndRead(ar);
            state.bufferPos = 0;
            processPackage(state);


        }
        void processPackage(StateObject state)
        {
            if (state.bufferSize == 0 || state.bufferPos == state.bufferSize) return;


            if (state.package == null)
            {
                using (MemoryStream ms = new MemoryStream(state.buffer))
                {
                    BinaryReader br = new BinaryReader(ms);
                    br.BaseStream.Position = state.packagePos;
                    state.packageSize = ReadInt(br.ReadBytes(4));
                    state.bufferPos += 4;
                    state.package = new byte[state.packageSize];
                    state.packagePos = 0;
                }

            }
            int l = Mathf.Min(state.packageSize - state.packagePos, state.bufferSize - state.bufferPos);

            Array.Copy(state.buffer, state.bufferPos, state.package, state.packagePos, l);
            state.packagePos += l;
            state.bufferPos += l;

            if (state.packagePos == state.packageSize)
            {
                DData data = DData.Read(state.package);
                if (!String.IsNullOrEmpty(data.Id))
                {
                    DCore.Handle(data);
                }
                state.packageSize = 0;
                state.packagePos = 0;
                state.package = null;
            }
            if(state.bufferPos < state.bufferSize){
                processPackage(state);
            }


        }
        void closeSocket(string msg){
            DUtils.Log(msg);
            //DUtils.resume();

        }

        void IConnection.ProcessQueue()
        {
            throw new NotImplementedException();
        }

        void IConnection.Send(string id, BaseVO data, bool direct)
        {
            throw new NotImplementedException();
        }
        int ReadInt(byte[] bytes){
            Array.Reverse(bytes);
            int i = BitConverter.ToInt32(bytes,0);
            return i;
        }
    }
    internal class StateObject{
        public TcpClient client = null;
        public int total = 0;

        public int packagePos = 0;
        public int packageSize = 0;
        public byte[] package = null;


        public int bufferPos = 0;
        public int bufferSize = 0;
        public byte[] buffer = new byte[BufferMaxSize];
        public const int BufferMaxSize = 1024 * 1024 * 2;
    }
}
