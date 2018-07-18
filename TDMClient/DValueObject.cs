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
}
