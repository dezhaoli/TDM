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

                    bw.Write(Convert(msgByte.Length));
                    bw.Write(msgByte);

                    _bytes = memoryStream.ToArray();
                    bw.Close();
                }


                return _bytes;
            }

            set
            {
                byte[] _bytes = value;
            }
        }

        public byte[] Convert(int i)
        {
            byte[] bytes = BitConverter.GetBytes(i);
            Array.Reverse(bytes);
            return bytes;
        }
        public static DData Read(byte[] bytes)
        {
            DData item = new DData("", null)
            {
                Bytes = bytes
            };
            return item;
        }
    }
}
