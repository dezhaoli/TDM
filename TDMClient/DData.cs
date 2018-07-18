using System;
using System.IO;
using System.Text;
using LitJson;

namespace TDMClient
{
    public class DData
    {
        private string _id;

        public string Id
        {
            get
            {
                return _id;
            }
        }

        private BaseVO _data;

        public BaseVO Data
        {
            get
            {
                return _data;
            }
        }

        public DData(string id,BaseVO data)
        {
            _id = id;
            _data = data;
        }

        public byte[] Bytes
        {
            get
            {
                byte[] _bytes;
                string msg = JsonMapper.ToJson(_data);
                using(MemoryStream memoryStream = new MemoryStream())
                {
                    BinaryWriter bw = new BinaryWriter(memoryStream);
                    byte[] msgByte = Encoding.UTF8.GetBytes(msg);
                    int msgLen = msgByte.Length;

                    bw.Write(Array.Reverse(BitConverter.GetBytes(msgLen)));
                    bw.Write(msgByte);

                    _bytes = memoryStream.ToArray();
                    bw.Close();
                }


                return _bytes;
            }
        }
    }
}
