using System;
using System.Collections;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Timers;
using UnityEngine;

namespace TDMClient
{
    public class DConnectionDefault : IConnection
    {
        // Max queue length
        private int MAX_QUEUE_LENGTH = 500;

        // Properties
        private TcpClient _socket;
        private bool _connecting;
        private bool _process;
        private Timer _retry;
        private Timer _timeout;
        private string _address;
        private int _port;

        // Data buffer
        private Queue _queue = new Queue();

        public DConnectionDefault()
        {
            _socket = new TcpClient();

            _address = "127.0.0.1";

            _connecting = false;
            _process = false;
#if UNITY_EDITOR
            _port =  10086;
#elif UNITY_ANDROID
            _port =  12580;
#endif
            _timeout = new Timer(2000);
            _timeout.AutoReset = false;
            _timeout.Elapsed += timeoutHandler;
            _retry = new Timer(1000);
            _retry.AutoReset = false;
            _retry.Elapsed += retryHandler;

        }

        public string Address
        {
            set
            {
                _address = value;
            }
        }
        /**
         * Get connected status.
         */
        public bool Connected{
            get
            {
                return _socket.Connected;
            }
        }
        /**
         *  Start processing the queue.
         */
        public void ProcessQueue()
        {
            if(!_process){
                _process = true;
                if(_queue.Count>0){
                    Next();
                }
            }
        }
        /**
         * Send data to the desktop application.
         * @param id: The id of the plugin
         * @param data: The data to send
         * @param direct: Use the queue or send direct (handshake)
         */
        public void Send(string id, BaseVO data, bool direct = false)
        {
            // Send direct (in case of handshake)
            if (direct && id == DCore.ID && _socket.Connected)
            {
                using (MemoryStream ms = new MemoryStream())
                {
                    BinaryWriter bw = new BinaryWriter(ms, UTF8Encoding.Default);
                    DData item = new DData(id, data);
                    byte[] bytes = item.Bytes;
                    bw.Write(bytes.Length);
                    bw.Write(Encoding.UTF8.GetBytes("LDZ"));
                    bw.Write(bytes);
                    var datas = ms.ToArray();
                    NetworkStream ns = _socket.GetStream();
                    ns.Write(datas, 0, datas.Length);
                    ns.Flush();
                    bw.Close();
                }
                return;
            }
            // Add to normal queue
            _queue.Enqueue(new DData(id, data));
            if (_queue.Count > MAX_QUEUE_LENGTH)
            {
                _queue.Dequeue();
            }
            if (_queue.Count > 0)
            {
                Next();
            }
        }
        /**
         * Connect the socket.
         */
        public void Connect()
        {
            if (!_connecting && TranslationDebugger.Enabled)
            {
                try
                {
                    DUtils.Log("BeginConnect!");
                    _connecting = true;
                    _retry.Stop();
                    _timeout.Start();

                    StateObject so = new StateObject();
                    so.client = _socket;

                    _socket.BeginConnect(_address, _port, ConnectHandler, so);

                }
                catch (Exception ex)
                {
                    closeHandler(ex.Message);
                }
            }

        }

        private void Next()
        {
            if (!TranslationDebugger.Enabled)
                return;
            if (!_process)
            {
                return;
            }
            if(!_socket.Connected)
            {
                Connect();
                return;
            }


            using (MemoryStream ms = new MemoryStream())
            {
                BinaryWriter bw = new BinaryWriter(ms, UTF8Encoding.Default);
                DData data = (DData)_queue.Dequeue();
                byte[] bytes = data.Bytes;
                bw.Write(bytes.Length);
                bw.Write(Encoding.UTF8.GetBytes("LDZ"));
                bw.Write(bytes);
                var datas = ms.ToArray();
                NetworkStream ns = _socket.GetStream();
                ns.Write(datas, 0, datas.Length);
                ns.Flush();
                bw.Close();
            }

            if(_queue.Count>0)
            {
                Next();
            }
        }

        private void ConnectHandler(IAsyncResult ar)
        {
            _timeout.Stop();
            _retry.Stop();

            _connecting = false;



            StateObject state = (StateObject)ar.AsyncState;
            TcpClient tcp = state.client;
            DUtils.Log("TranslationDebugger Connected:"+ tcp.Connected);

            try{
                tcp.EndConnect(ar);
                if (tcp.Connected)
                {
                    NetworkStream ns = tcp.GetStream();

                    byte[] hello = Encoding.UTF8.GetBytes("<hello/>");
                    ns.Write(hello, 0, hello.Length);
                    ns.Flush();
                    //Shortcut.start();
                    if (ns.CanRead)
                    {
                        ns.BeginRead(state.buffer, 0, StateObject.BufferMaxSize, dataHandler, state);
                        return;
                    }
                }
                closeHandler("Some error occur.Close nonnection...");
            }
            catch(Exception ex)
            {
                closeHandler("TranslationDebugger connection failed:" + ex.Message);
            }

        }
        /**
         * Retry is done.
         */
        void retryHandler(object sender, ElapsedEventArgs e)
        {
            _retry.Stop();
            Connect();
        }
        void timeoutHandler(object sender, ElapsedEventArgs e)
        {
            closeHandler("connect timeout...");
        }

        /**
         * Connection closed.
         * Due to a timeout or connection error.
         */
        void closeHandler(string msg = "")
        {
            Disconnect();
            if (!String.IsNullOrEmpty(msg))
            {
                DUtils.Log(msg);
            }
            // Resume if we have paused the applicatio we're debugging
            //DUtils.resume();
            if (!_retry.Enabled)
            {
                _connecting = false;
                _process = false;
                _timeout.Stop();
                _retry.Start();
                DUtils.Log("start retry timer...");
            }
            //Shortcut.stop();
        }
        void dataHandler(IAsyncResult ar)
        {
            StateObject state = (StateObject)ar.AsyncState;
            TcpClient tcp = state.client;
            NetworkStream ns = tcp.GetStream();
            if(!tcp.Connected){
                closeHandler("TDC lost connection...");
                return;
            }
            state.bufferSize = ns.EndRead(ar);
            state.bufferPos = 0;
            ProcessPackage(state);


        }
        void ProcessPackage(StateObject state)
        {
            if (state.bufferSize == 0 || state.bufferPos == state.bufferSize) return;


            if (state.package == null)
            {
                using (MemoryStream ms = new MemoryStream(state.buffer))
                {
                    BinaryReader br = new BinaryReader(ms);
                    br.BaseStream.Position = state.packagePos;
                    state.packageSize = br.ReadInt32();
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
                ProcessPackage(state);
            }

        }

        public void Disconnect()
        {
            if (_socket != null)
            {
                _socket.Close();

                _socket = new TcpClient();
            }
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
