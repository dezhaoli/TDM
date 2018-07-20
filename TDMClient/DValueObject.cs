using System;
using UnityEngine;
namespace TDMClient
{
    public class DValueObject
    {
        public DValueObject()
        {
        }
    }
    [SerializeField]
    public class BaseVO
    {
        public string command;
        public string msg;
    }
    [SerializeField]
    public class TraceVO : BaseVO
    {
        public uint memory;
        public DateTime date;
        public string target;
        public string reference;
        public string xml;
        public string persion;
        public string label;
        public uint color;
    }
    [SerializeField]
    public class InfoVO : BaseVO
    {
        public int debuggerVersion;
        public string playerType;
        public string playerVersion;
        public bool isDebugger;
        public string xml;
        public string fileLocation;
        public string fileTitle;
        public string[] kvs;
    }

}
