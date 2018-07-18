using System;
using System.Dynamic;

namespace Test
{
    class MainClass
    {
        public static void Main(string[] args)
        {
            dynamic obj = new System.Dynamic.ExpandoObject();
            obj.A = "a";



            Console.WriteLine("Hello World!"+obj.A);
        }
    }
}
