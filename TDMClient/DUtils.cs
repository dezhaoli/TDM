﻿using System;
using System.Collections.Generic;
using UnityEngine;
namespace TDMClient
{
    /**
     * @private
     * The Translation Debugger static utilities
     */
    internal class DUtils
    {
        public static void Log(object msg){
            Debug.Log(msg);
        }

        // References
        private static Dictionary<WeakReference, object> _references = new Dictionary<WeakReference, object>();
        private static int _reference = 0;


        /**
         * Create a BitmapData representation of an object.
         * @param object: The object to draw
         * @param rectangle: (Optional) bounding rectangle
         */
        //public static function snapshot(object:DisplayObject, rectangle:Rectangle = null):BitmapData
        //{
        //    // Return if object is not found
        //    if (object == null) {
        //        return null;
        //    }

        //    // Save vars
        //    var visible:Boolean = object.visible;
        //    var alpha:Number = object.alpha;
        //    var rotation:Number = object.rotation;
        //    var scaleX:Number = object.scaleX;
        //    var scaleY:Number = object.scaleY;

        //    // Reset vars
        //    try {
        //        object.visible = true;
        //        object.alpha = 1;
        //        object.rotation = 0;
        //        object.scaleX = 1;
        //        object.scaleY = 1;
        //    } catch (e1:Error) {
        //        //
        //    }

        //    // Check for null size
        //    var bounds:Rectangle = object.getBounds(object);
        //    bounds.x = int(bounds.x + 0.5);
        //    bounds.y = int(bounds.y + 0.5);
        //    bounds.width = int(bounds.width + 0.5);
        //    bounds.height = int(bounds.height + 0.5);
        //    if (object is Stage) {
        //        bounds.x = 0;
        //        bounds.y = 0;
        //        bounds.width = Stage(object).stageWidth;
        //        bounds.height = Stage(object).stageHeight;
        //    }

        //    // Return bitmap data
        //    var bitmapData:BitmapData = null;
        //    var m:Matrix;

        //    // Return if no size
        //    if (bounds.width <= 0 || bounds.height <= 0) {
        //        return null;
        //    }

        //    // Create the bitmap
        //    try {
        //        bitmapData = new BitmapData(bounds.width, bounds.height, false, 0xFFFFFF);
        //        m = new Matrix();
        //        m.tx = -bounds.x;
        //        m.ty = -bounds.y;
        //        bitmapData.draw(object, m, null, null, null, false);
        //    } catch (e2:Error) {
        //        bitmapData = null;
        //        // TODO: Crossdomain warning
        //    }

        //    // Restore
        //    try {
        //        object.visible = visible;
        //        object.alpha = alpha;
        //        object.rotation = rotation;
        //        object.scaleX = scaleX;
        //        object.scaleY = scaleY;
        //    } catch (e3:Error) {
        //        //
        //    }

        //    // Return 
        //    if (bitmapData == null) {
        //        return null;
        //    }

        //    // Check if we should scale the result
        //    if (rectangle != null) {

        //        // Don't upscale
        //        if (bounds.width <= rectangle.width && bounds.height <= rectangle.height) {
        //            return bitmapData;
        //        }

        //        // Scale
        //        var scaled:Rectangle = bounds.clone();
        //        scaled.width = rectangle.width;
        //        scaled.height = rectangle.width * (bounds.height / bounds.width);
        //        if (scaled.height > rectangle.height) {
        //            scaled = bounds.clone();
        //            scaled.width = rectangle.height * (bounds.width / bounds.height);
        //            scaled.height = rectangle.height;
        //        }

        //        // Return scaled data
        //        var s:Number = scaled.width / bounds.width;
        //        try {
        //            var b:BitmapData = new BitmapData(scaled.width, scaled.height, false, 0x000000);
        //            m = new Matrix();
        //            m.scale(s, s);
        //            b.draw(bitmapData, m, null, null, null, true);
        //            bitmapData.dispose();
        //            bitmapData = b;
        //        } catch (e4:Error) {
        //            bitmapData.dispose();
        //            bitmapData = null;
        //        }
        //    }

        //    return bitmapData;
        //}       


        /**
         * Returns the system memory.
         */
        public static uint GetMemory()
        {
            return (uint)System.GC.GetTotalMemory(true);
            //return (uint)System.Diagnostics.Process.GetCurrentProcess().VirtualMemorySize64;
        }


        /**
         * Pause the application.
         */
        public static bool Pause()
        {
            try
            {
                Time.timeScale = 0;
                return true;
            }
            catch (Exception e) { }
            return false;
        }


        /**
         * Resume the application.
         */
        public static bool resume()
        {
            try
            {
                Time.timeScale = 1;
                return true;
            }
            catch (Exception e) { }
            return false;
        }


        /**
         * Get a stack trace after a break point.
         */
        //public static function stackTrace():XML
        //{
        //    // Variables needed in the loops
        //    var rootXML:XML = new XML("<root/>");
        //    var childXML:XML = new XML("<node/>");

        //    // Generate an error
        //    try {
        //        throw(new Error());
        //    } catch (e:Error) {

        //        // Get the stack 
        //        var stack:String = e.getStackTrace();
        //        if (stack == null || stack == "") {
        //            return new XML("<root><error>Stack unavailable</error></root>");
        //        }

        //        // Remove tabs
        //        stack = stack.split("\t").join("");

        //        var lines:Array = stack.split("\n");
        //        if (lines.length <= 4) return new XML("<root><error>Stack to short</error></root>");
        //        lines.shift(); // Error
        //        lines.shift(); // TranslationDebugger
        //        lines.shift(); // TranslationDebuggerCore
        //        lines.shift(); // TranslationDebuggerUtils

        //        // Parse
        //        for (var i:int = 0; i < lines.length; i++)
        //        {
        //            // Remove "at "
        //            var s:String = lines[i];
        //            s = s.substring(3, s.length);

        //            // Bracket index
        //            var bracketIndex:int = s.indexOf("[");
        //            var methodIndex:int = s.indexOf("/");
        //            if (bracketIndex == -1) bracketIndex = s.length;
        //            if (methodIndex == -1) methodIndex = bracketIndex;

        //            // Properties
        //            var classname:String = DUtils.parseType(s.substring(0, methodIndex));
        //            var method:String = "";
        //            var file:String = "";
        //            var line:String = "";

        //            // Get functions and file
        //            if (methodIndex != s.length && methodIndex != bracketIndex) {
        //                method = s.substring(methodIndex + 1, bracketIndex);
        //            }
        //            if (bracketIndex != s.length) {
        //                file = s.substring(bracketIndex + 1, s.lastIndexOf(":"));
        //                line = s.substring(s.lastIndexOf(":") + 1, s.length - 1);
        //            }

        //            //  an empty function
        //            var functionXML:XML = new XML("<node/>");
        //            functionXML.@classname  = classname;
        //            functionXML.@method     = method;
        //            functionXML.@file       = file;
        //            functionXML.@line       = line;
        //            childXML.appendChild(functionXML);
        //        }
        //    }

        //    // Return
        //    rootXML.appendChild(childXML.children());
        //    return rootXML;
        //}


        /**
         * Get a reference id from a target.
         */
        public static string getReferenceID(object target)
        {
            //if (target in _references) {
            //    return _references[target];
            //}
            var reference = "#" + _reference.ToString();
            //_references[target] = reference;
            _reference++;
            return reference;
        }


        /**
         * Get a target from a reference id.
         */
        public static object getReference(string id)
        {
            // Check for reference id
            if (id.StartsWith("#",StringComparison.CurrentCulture) )
            {
                return null;
            }

            // Check if the key is still there
            //for (var key:* in _references) {
            //    var value:String = _references[key];
            //    if (value == id) {
            //        return key;
            //    }
            //}
            return null;
        }


        /**
         * Convert a point seperated path to an object and return that object.
         * @param base: The base of the application
         * @param target: A point seperated path to the object or reference ID (starting with #)
         * @param parent: The parent number relative to the path
         */
        //public static object getObject(object baseObj, string target = "", int parent = 0)
        //{           
        //    // Check if the path is not empty
        //    if (target == null || target == "") {
        //        return baseObj;
        //    }

        //    // Check for reference id
        //    if (target.charAt(0) == "#") {
        //        return getReference(target);
        //    }

        //    // Set base
        //    var object = baseObj;

        //    // Split the path
        //    var splitted:Array = target.split(DConstants.DELIMITER);

        //    // Loop through the array
        //    for (var i:int = 0; i < splitted.length - parent; i++)
        //    {
        //        // Check if the string isn't empty
        //        if (splitted[i] != "") 
        //        {
        //            try
        //            {
        //                // Check if we should call the XML children function()
        //                // Or the getChildAt function
        //                // If not: Just update the path to the object
        //                if (splitted[i] == "children()") {
        //                    object = object.children();
        //                } else if (object is DisplayObjectContainer && splitted[i].indexOf("getChildAt(") == 0) {
        //                    var index:Number = splitted[i].substring(11, splitted[i].indexOf(")", 11));
        //                    object = DisplayObjectContainer(object).getChildAt(index);
        //                } else {
        //                    object = object[splitted[i]];
        //                }
        //            }
        //            catch (e:Error)
        //            {
        //                // The object is not found
        //                // This can be a ReferenceError or a RangeError
        //                break;
        //            }
        //        }
        //    }

        //    // Return the object
        //    return object;
        //}


        /**
         * Parse an object.
         * @param object: The object to parse
         * @param target: A point seperated path to the object
         * @param currentDepth: The current  depth
         * @param maxDepth: The maximum  depth
         * @param includeDisplayObjects: Include display objects
         */
        public static string Parse(object obj, string target = "", int currentDepth = 1, int maxDepth = 5,bool includeDisplayObjects = true)
        {
            var rootXML = "";
        //    // Variables needed in the loops
        //    var rootXML:XML = new XML("<root/>");
        //    var childXML:XML = new XML("<node/>");
        //    var description:XML = new XML();
        //    var type:String = "";
        //    var base:String = "";
        //    var isDynamic:Boolean = false;
        //    var label:String = null;        
        //    var icon:String = DConstants.ICON_ROOT;
        //    var name:String="";

        //    // Check if the max  depth is reached
        //    if (maxDepth != -1 && currentDepth > maxDepth) {
        //        return rootXML;
        //    }

        //    // Null object
        //    if (object == null)
        //    {
        //        type = "null";
        //        label = "null";
        //        icon = DConstants.ICON_WARNING;
        //    }
        //    else
        //    {
        //        // Get the descriptor
        //        description = DDescribeType.get(object);
        //        type = parseType(description.@name);
        //        base = parseType(description.@base);
        //        isDynamic = description.@isDynamic;

        //        // Check for class type
        //        if (object is Class)
        //        {
        //            // The object is a class value, this will show the static properties
        //            label = "Class = " + type;
        //            type = "Class";
        //            childXML.appendChild(parseClass(object, target, description, currentDepth, maxDepth, includeDisplayObjects).children());
        //        }
        //        else if (type == DConstants.TYPE_XML)
        //        {
        //            childXML.appendChild(parseXML(object, target + ".children()", currentDepth, maxDepth).children());
        //        }
        //        else if (type == DConstants.TYPE_XMLLIST)
        //        {
        //            label = type + " [" + String(object.length()) + "]";
        //            childXML.appendChild(parseXMLList(object, target, currentDepth, maxDepth).children());
        //        }
        //        else if (type == DConstants.TYPE_ARRAY || type.indexOf(DConstants.TYPE_VECTOR) == 0)
        //        {
        //            label = type + " [" + String(object["length"]) + "]";
        //            childXML.appendChild(parseArray(object, target, currentDepth, maxDepth).children());
        //        }
        //        else if (type == DConstants.TYPE_STRING || type == DConstants.TYPE_BOOLEAN || type == DConstants.TYPE_NUMBER || type == DConstants.TYPE_INT || type == DConstants.TYPE_UINT)
        //        {
        //            childXML.appendChild(parseBasics(object, target, type).children());
        //        }
        //        else if (type == DConstants.TYPE_OBJECT)
        //        {
        //            childXML.appendChild(parseObject(object, target, currentDepth, maxDepth, includeDisplayObjects).children());
        //        }
        //        else
        //        {
        //            childXML.appendChild(parseClass(object, target, description, currentDepth, maxDepth, includeDisplayObjects).children());
        //        }
        //    }

        //    if (currentDepth == 1)
        //    {
        //        // Save the extra info
        //        var topXML:XML = new XML("<node/>");
        //        topXML.@icon = icon;
        //        topXML.@label = ("name" in object && object.name )? object.name+":"+type:type;
        //        topXML.@type = type;
        //        topXML.@target = target;
        //        topXML.@name = ("name" in object)? object.name:"";

        //        // Check for fixed label
        //        if (label != null) {
        //            topXML.@label = label;
        //        }

        //        // First add the top then the child nodes
        //        topXML.appendChild(childXML.children());
        //        rootXML.appendChild(topXML);
        //    } else {
        //        rootXML.appendChild(childXML.children());
        //    }

        //    // Return the xml
            return obj.ToString();
        }


        ///**
        // * Parse a String, Number, Boolean, ect.
        // * @param object: The object to parse
        // * @param target: A point seperated path to the object
        // * @param type: The object type
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // */
        //private static function parseBasics(object:*, target:String, type:String):XML
        //{           
        //    // Return type and properties
        //    var rootXML:XML = new XML("<root/>");
        //    var nodeXML:XML = new XML("<node/>");

        //    // Parse the basic type
        //    nodeXML.@icon           = DConstants.ICON_VARIABLE;
        //    nodeXML.@access         = DConstants.ACCESS_VARIABLE;
        //    nodeXML.@permission     = DConstants.PERMISSION_READWRITE;
        //    nodeXML.@label          = type + " = " + printValue(object, type, true); 
        //    nodeXML.@name           = "";
        //    nodeXML.@type           = type; 
        //    nodeXML.@value          = printValue(object, type); 
        //    nodeXML.@target         = target;

        //    // Add to parent
        //    rootXML.appendChild(nodeXML);

        //    // Return
        //    return rootXML;
        //}


        ///**
        // * Parse an Array or Vector.
        // * @param object: The object to parse
        // * @param target: A point seperated path to the object
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // */
        //private static function parseArray(object:*, target:String, currentDepth:int = 1, maxDepth:int = 5, includeDisplayObjects:Boolean = true):XML
        //{
        //    // Return type and properties
        //    var rootXML:XML = new XML("<root/>");
        //    var childXML:XML;
        //    var childType:String = "";
        //    var childTarget:String = "";
        //    var i:int = 0;

        //    // Get and sort the properties
        //    var keys:Array = [];
        //    var isNumeric:Boolean = true;
        //    for (var key:* in object) {
        //        if (!(key is int)) {
        //            isNumeric = false;
        //        }
        //        keys.push(key);
        //    }
        //    if (isNumeric) {
        //        keys.sort(Array.NUMERIC);
        //    } else {
        //        keys.sort(Array.CASEINSENSITIVE);
        //    }

        //    // Loop through the array
        //    for (i = 0; i < keys.length; i++)
        //    {
        //        // Save the type
        //        childType = parseType(DDescribeType.get(object[keys[i]]).@name);
        //        childTarget = target + "." + String(keys[i]);

        //        // Check if we can create a single string or a new node
        //        if (childType == DConstants.TYPE_STRING || childType == DConstants.TYPE_BOOLEAN || childType == DConstants.TYPE_NUMBER || childType == DConstants.TYPE_INT || childType == DConstants.TYPE_UINT || childType == DConstants.TYPE_FUNCTION)
        //        {
        //            // Parse the basic type
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_VARIABLE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = "[" + keys[i] + "] (" + childType + ") = " + printValue(object[keys[i]], childType, true); 
        //            childXML.@name          = "[" + keys[i] + "]";
        //            childXML.@type          = childType; 
        //            childXML.@value         = printValue(object[keys[i]], childType); 
        //            childXML.@target        = childTarget;
        //            rootXML.appendChild(childXML);
        //        }
        //        else
        //        {
        //            // Parse the array
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_VARIABLE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = "[" + keys[i] + "] (" + childType + ")"; 
        //            childXML.@name          = "[" + keys[i] + "]";
        //            childXML.@type          = childType; 
        //            childXML.@value         = "" ;
        //            childXML.@target        = childTarget;

        //            // Check for null object
        //            if (object[keys[i]] == null) {
        //                childXML.@icon = DConstants.ICON_WARNING;
        //                childXML.@label += " = null";
        //            }

        //            // Try to parse the object
        //            childXML.appendChild(parse(object[keys[i]], childTarget, currentDepth + 1, maxDepth, includeDisplayObjects).children());

        //            // Add to parent
        //            rootXML.appendChild(childXML);
        //        }
        //    }

        //    // Return
        //    return rootXML;
        //}


        ///**
        // * Parse an XML node.
        // * @param xml: The xml to parse
        // * @param target: A point seperated path to the object
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // */
        //public static function parseXML(xml:*, target:String = "", currentDepth:int = 1, maxDepth:int = -1):XML
        //{
        //    // Create a return string
        //    var rootXML:XML = new XML("<root/>");
        //    var nodeXML:XML;
        //    var childXML:XML;
        //    var i:int = 0;

        //    // Check if the max depth is reached
        //    if (maxDepth != -1 && currentDepth > maxDepth) {
        //        return rootXML;
        //    }

        //    // Check if the user selected an attribute
        //    if (target.indexOf("@") != -1)
        //    {
        //        // Display a single attribute
        //        nodeXML = new XML("<node/>");
        //        nodeXML.@icon           = DConstants.ICON_XMLATTRIBUTE;
        //        nodeXML.@type           = DConstants.TYPE_XMLATTRIBUTE;
        //        nodeXML.@access         = DConstants.ACCESS_VARIABLE;
        //        nodeXML.@permission     = DConstants.PERMISSION_READWRITE;
        //        nodeXML.@label          = xml;
        //        nodeXML.@name           = "";
        //        nodeXML.@value          = xml;
        //        nodeXML.@target         = target;
        //        rootXML.appendChild(nodeXML);
        //    }
        //    else if ("name" in xml && xml.name() == null)
        //    {
        //        // Only a text value
        //        nodeXML = new XML("<node/>");
        //        nodeXML.@icon           = DConstants.ICON_XMLVALUE;
        //        nodeXML.@type           = DConstants.TYPE_XMLVALUE;
        //        nodeXML.@access         = DConstants.ACCESS_VARIABLE;
        //        nodeXML.@permission     = DConstants.PERMISSION_READWRITE;
        //        nodeXML.@label          = "(" + DConstants.TYPE_XMLVALUE + ") = " + printValue(xml, DConstants.TYPE_XMLVALUE, true);
        //        nodeXML.@name           = "";
        //        nodeXML.@value          = printValue(xml, DConstants.TYPE_XMLVALUE);
        //        nodeXML.@target         = target;
        //        rootXML.appendChild(nodeXML);
        //    }
        //    else if ("hasSimpleContent" in xml && xml.hasSimpleContent())
        //    {
        //        // Node with one text value and possible attributes
        //        nodeXML = new XML("<node/>");
        //        nodeXML.@icon           = DConstants.ICON_XMLNODE;
        //        nodeXML.@type           = DConstants.TYPE_XMLNODE;
        //        nodeXML.@access         = DConstants.ACCESS_VARIABLE;
        //        nodeXML.@permission     = DConstants.PERMISSION_READWRITE;
        //        nodeXML.@label          = xml.name() + " (" + DConstants.TYPE_XMLNODE + ")";
        //        nodeXML.@name           = xml.name();
        //        nodeXML.@value          = "";
        //        nodeXML.@target         = target;

        //        // Only a text value
        //        if (xml != "") {
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_XMLVALUE;
        //            childXML.@type          = DConstants.TYPE_XMLVALUE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = "(" + DConstants.TYPE_XMLVALUE + ") = " + printValue(xml, DConstants.TYPE_XMLVALUE);
        //            childXML.@name          = "";
        //            childXML.@value         = printValue(xml, DConstants.TYPE_XMLVALUE);
        //            childXML.@target        = target;
        //            nodeXML.appendChild(childXML);
        //        }

        //        // Loop through the arrributes
        //        for (i = 0; i < xml.attributes().length(); i++)
        //        {
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_XMLATTRIBUTE;
        //            childXML.@type          = DConstants.TYPE_XMLATTRIBUTE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = "@" + xml.attributes()[i].name() + " (" + DConstants.TYPE_XMLATTRIBUTE + ") = " + xml.attributes()[i];
        //            childXML.@name          = "";
        //            childXML.@value         = xml.attributes()[i];                  
        //            childXML.@target        = target + "." + "@" + xml.attributes()[i].name();
        //            nodeXML.appendChild(childXML);
        //        }

        //        // Add to parent
        //        rootXML.appendChild(nodeXML);
        //    }
        //    else
        //    {
        //        // Node with children and attributes
        //        // This node has no value due to the children
        //        nodeXML = new XML("<node/>");
        //        nodeXML.@icon           = DConstants.ICON_XMLNODE;
        //        nodeXML.@type           = DConstants.TYPE_XMLNODE;
        //        nodeXML.@access         = DConstants.ACCESS_VARIABLE;
        //        nodeXML.@permission     = DConstants.PERMISSION_READWRITE;
        //        nodeXML.@label          = xml.name() + " (" + DConstants.TYPE_XMLNODE + ")";
        //        nodeXML.@name           = xml.name();
        //        nodeXML.@value          = "";
        //        nodeXML.@target         = target;

        //        // Loop through the arrributes
        //        for (i = 0; i < xml.attributes().length(); i++)
        //        {
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_XMLATTRIBUTE;
        //            childXML.@type          = DConstants.TYPE_XMLATTRIBUTE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = "@" + xml.attributes()[i].name() + " (" + DConstants.TYPE_XMLATTRIBUTE + ") = " + xml.attributes()[i];
        //            childXML.@name          = "";
        //            childXML.@value         = xml.attributes()[i];
        //            childXML.@target        = target + "." + "@" + xml.attributes()[i].name();
        //            nodeXML.appendChild(childXML);
        //        }

        //        // Loop through children
        //        for (i = 0; i < xml.children().length(); i++)
        //        {
        //            var childTarget:String = target + "." + "children()" + "." + i;
        //            nodeXML.appendChild(parseXML(xml.children()[i], childTarget, currentDepth + 1, maxDepth).children());
        //        }

        //        // Add to parent
        //        rootXML.appendChild(nodeXML);
        //    }

        //    //Return the xml
        //    return rootXML;
        //}


        ///**
        // * Parse an XML list.
        // * @param xml: The xml to parse
        // * @param target: A point seperated path to the object
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // */
        //public static function parseXMLList(xml:*, target:String = "", currentDepth:int = 1, maxDepth:int = -1):XML
        //{
        //    // Create a return string
        //    var rootXML:XML = new XML("<root/>");

        //    // Check if the max depth is reached
        //    if (maxDepth != -1 && currentDepth > maxDepth) {
        //        return rootXML;
        //    }

        //    // Loop through the xml nodes
        //    for (var i:int = 0; i < xml.length(); i++) {                
        //        rootXML.appendChild(parseXML(xml[i], target + "." + String(i) + ".children()", currentDepth, maxDepth).children());
        //    }

        //    return rootXML;
        //}


        ///**
        // * Parse an Object.
        // * @param object: The object to parse
        // * @param target: A point seperated path to the object
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // * @param includeDisplayObjects: Include display objects
        // */
        //private static function parseObject(object:*, target:String, currentDepth:int = 1, maxDepth:int = 5, includeDisplayObjects:Boolean = true):XML
        //{
        //    // Return type and properties
        //    var rootXML:XML = new XML("<root/>");
        //    var nodeXML:XML = new XML("<node/>");
        //    var childXML:XML;
        //    var childType:String = "";
        //    var childTarget:String = "";
        //    var i:int = 0;

        //    // Get and sort the properties
        //    var properties:Array = [];
        //    var isNumeric:Boolean = true;
        //    for (var prop:* in object) {
        //        if (!(prop is int)) {
        //            isNumeric = false;
        //        }
        //        properties.push(prop);
        //    }
        //    if (isNumeric) {
        //        properties.sort(Array.NUMERIC);
        //    } else {
        //        properties.sort(Array.CASEINSENSITIVE);
        //    }

        //    // Loop through the array
        //    for (i = 0; i < properties.length; i++)
        //    {
        //        childType = parseType(DDescribeType.get(object[properties[i]]).@name);
        //        childTarget = target + "." + properties[i];

        //        // Check if we can create a single string or a new node
        //        if (childType == DConstants.TYPE_STRING || childType == DConstants.TYPE_BOOLEAN || childType == DConstants.TYPE_NUMBER || childType == DConstants.TYPE_INT || childType == DConstants.TYPE_UINT || childType == DConstants.TYPE_FUNCTION)
        //        {
        //            // Parse the basic type
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_VARIABLE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = properties[i] + " (" + childType + ") = " + printValue(object[properties[i]], childType, true); 
        //            childXML.@name          = properties[i];
        //            childXML.@type          = childType; 
        //            childXML.@value         = printValue(object[properties[i]], childType); 
        //            childXML.@target        = childTarget;
        //            nodeXML.appendChild(childXML);
        //        }
        //        else
        //        {
        //            // Parse the object
        //            childXML = new XML("<node/>");
        //            childXML.@icon          = DConstants.ICON_VARIABLE;
        //            childXML.@access        = DConstants.ACCESS_VARIABLE;
        //            childXML.@permission    = DConstants.PERMISSION_READWRITE;
        //            childXML.@label         = properties[i] + " (" + childType + ")"; 
        //            childXML.@name          = properties[i];
        //            childXML.@type          = childType; 
        //            childXML.@value         = "" ;
        //            childXML.@target        = childTarget;

        //            // Check for null object
        //            if (object[properties[i]] == null) {
        //                childXML.@icon = DConstants.ICON_WARNING;
        //                childXML.@label += " = null";
        //            }

        //            // Try to parse the object
        //            childXML.appendChild(parse(object[properties[i]], childTarget, currentDepth + 1, maxDepth, includeDisplayObjects).children());

        //            // Add to parent
        //            nodeXML.appendChild(childXML);
        //        }
        //    }

        //    // Add to parent
        //    rootXML.appendChild(nodeXML.children());

        //    // Return
        //    return rootXML;
        //}


        ///**
        // * Parse a Class.
        // * @param object: The object to parse
        // * @param target: A point seperated path to the object
        // * @param description: The describe type XML
        // * @param currentDepth: The current  depth
        // * @param maxDepth: The maximum  depth
        // * @param includeDisplayObjects: Include display objects
        // */
        //private static function parseClass(object:*, target:String, description:XML, currentDepth:int = 1, maxDepth:int = 5, includeDisplayObjects:Boolean = true):XML
        //{
        //    var rootXML:XML = new XML("<root/>");
        //    var nodeXML:XML = new XML("<node/>");
        //    var variables:XMLList = description..variable;
        //    var accessors:XMLList = description..accessor;
        //    var constants:XMLList = description..constant;
        //    var isDynamic:Boolean = description.@isDynamic;
        //    var variablesLength:int = variables.length();
        //    var accessorsLength:int = accessors.length();
        //    var constantsLength:int = constants.length();
        //    var childLength:int = 0;
        //    var key:String;
        //    var keys:Object = {};
        //    var itemsArray:Array = [];
        //    var itemsArrayLength:int;
        //    var item:*;
        //    var itemXML:XML;
        //    var itemAccess:String;
        //    var itemPermission:String;
        //    var itemIcon:String;
        //    var itemType:String;
        //    var itemName:String;
        //    var itemTarget:String;
        //    var i:int;

        //    // Save dynamic properties
        //    if (isDynamic) {

        //        for (var prop:* in object) {
        //            key = String(prop);
        //            if (!keys.hasOwnProperty(key)) {
        //                keys[key] = key;
        //                itemName = key;
        //                itemType = parseType(getQualifiedClassName(object[key]));
        //                itemTarget = target + "." + key;
        //                itemAccess = DConstants.ACCESS_VARIABLE;
        //                itemPermission = DConstants.PERMISSION_READWRITE;
        //                itemIcon = DConstants.ICON_VARIABLE;
        //                itemsArray[itemsArray.length] = {
        //                    name:           itemName,
        //                    type:           itemType,
        //                    target:         itemTarget,
        //                    access:         itemAccess,
        //                    permission:     itemPermission,
        //                    icon:           itemIcon
        //                };
        //            }
        //        }
        //    }

        //    // Save the variables
        //    for (i = 0; i < variablesLength; i++) {
        //        key = variables[i].@name;
        //        if (!keys.hasOwnProperty(key)) {


        //            keys[key] = key;
        //            itemName = key;
        //            itemType = parseType(variables[i].@type);

        //            itemTarget = target + "." + key;
        //            itemAccess = DConstants.ACCESS_VARIABLE;
        //            itemPermission = DConstants.PERMISSION_READWRITE;
        //            itemIcon = DConstants.ICON_VARIABLE;
        //            itemsArray[itemsArray.length] = {
        //                name:           itemName,
        //                type:           itemType,
        //                target:         itemTarget,
        //                access:         itemAccess,
        //                permission:     itemPermission,
        //                icon:           itemIcon
        //            };
        //        }
        //    }

        //    // Save the accessors
        //    for (i = 0; i < accessorsLength; i++) {
        //        key = accessors[i].@name;
        //        if (!keys.hasOwnProperty(key)) {
        //            keys[key] = key;
        //            itemName = key;
        //            itemType = parseType(accessors[i].@type);
        //            itemTarget = target + "." + key;
        //            itemAccess = DConstants.ACCESS_ACCESSOR;
        //            itemPermission = DConstants.PERMISSION_READWRITE;
        //            itemIcon = DConstants.ICON_VARIABLE;
        //            if (accessors[i].@access == DConstants.PERMISSION_READONLY) {
        //                itemPermission = DConstants.PERMISSION_READONLY;
        //                itemIcon = DConstants.ICON_VARIABLE_READONLY;
        //            }
        //            if (accessors[i].@access == DConstants.PERMISSION_WRITEONLY) {
        //                itemPermission = DConstants.PERMISSION_WRITEONLY;
        //                itemIcon = DConstants.ICON_VARIABLE_WRITEONLY;
        //            }
        //            itemsArray[itemsArray.length] = {
        //                name:           itemName,
        //                type:           itemType,
        //                target:         itemTarget,
        //                access:         itemAccess,
        //                permission:     itemPermission,
        //                icon:           itemIcon
        //            };
        //        }
        //    }

        //    // Save the constants
        //    for (i = 0; i < constantsLength; i++) {
        //        key = constants[i].@name;
        //        if (!keys.hasOwnProperty(key)) {
        //            keys[key] = key;
        //            itemName = key;
        //            itemType = parseType(constants[i].@type);
        //            itemTarget = target + "." + key;
        //            itemAccess = DConstants.ACCESS_CONSTANT;
        //            itemPermission = DConstants.PERMISSION_READONLY;
        //            itemIcon = DConstants.ICON_VARIABLE_READONLY;
        //            itemsArray[itemsArray.length] = {
        //                name:           itemName,
        //                type:           itemType,
        //                target:         itemTarget,
        //                access:         itemAccess,
        //                permission:     itemPermission,
        //                icon:           itemIcon
        //            };
        //        }
        //    }

        //    // Sort the nodes
        //    itemsArray.sortOn("name", Array.CASEINSENSITIVE);

        //    //var filterItems:Array = []
        //    //for (var j:int = 0; j < itemsArray.length; j++) 
        //    //{
        //        //var o:Object = itemsArray[j];
        //        //if (TranslationDebuggerConstants.AttisonProp[ o.name ]) {
        //            //filterItems.push(o);
        //        //}
        //    //}
        //    //itemsArray = filterItems;

        //    // Get the number of children
        //    if (includeDisplayObjects && object is DisplayObjectContainer) {
        //        var displayObject:DisplayObjectContainer = DisplayObjectContainer(object);
        //        var displayObjects:Array = [];
        //        childLength = displayObject.numChildren;
        //        for (i = 0; i < childLength; i++) {
        //            var child:DisplayObject = null;
        //            try {
        //                child = displayObject.getChildAt(i);
        //            } catch (e1:Error) {
        //                //
        //            }
        //            if (child != null) {
        //                itemXML = DDescribeType.get(child);
        //                itemType = parseType(itemXML.@name);
        //                itemName = "DisplayObject";
        //                if (child.name != null) {
        //                    itemName += " - " + child.name;
        //                }
        //                itemTarget = target + "." + "getChildAt(" + i + ")";
        //                itemAccess = DConstants.ACCESS_DISPLAY_OBJECT;
        //                itemPermission = DConstants.PERMISSION_READWRITE;
        //                itemIcon = child is DisplayObjectContainer ? DConstants.ICON_ROOT : DConstants.ICON_DISPLAY_OBJECT;
        //                displayObjects[displayObjects.length] = {
        //                    name:           itemName,
        //                    type:           itemType,
        //                    target:         itemTarget,
        //                    access:         itemAccess,
        //                    permission:     itemPermission,
        //                    icon:           itemIcon,
        //                    index:          i
        //                };
        //            }
        //        }

        //        // Sort and concat
        //        displayObjects.sortOn("name", Array.CASEINSENSITIVE);
        //        itemsArray = displayObjects.concat(itemsArray);
        //    }

        //    // Save length
        //    itemsArrayLength = itemsArray.length;

        //    // VARIABLES
        //    for (i = 0; i < itemsArrayLength; i++)
        //    {
        //        // Save the type
        //        itemType = itemsArray[i].type;
        //        itemName = itemsArray[i].name;
        //        itemTarget = itemsArray[i].target;
        //        itemPermission = itemsArray[i].permission;
        //        itemAccess = itemsArray[i].access;
        //        itemIcon = itemsArray[i].icon;

        //        // Don't include write only items (gives an error)
        //        if (itemPermission == DConstants.PERMISSION_WRITEONLY) {
        //            continue;
        //        }

        //        // Get the child or property
        //        try {
        //            if (itemAccess == DConstants.ACCESS_DISPLAY_OBJECT) {
        //                item = DisplayObjectContainer(object).getChildAt(itemsArray[i].index);
        //            } else {
        //                item = object[itemName];
        //            }
        //        } catch (e2:Error) {
        //            item = null;
        //        }

        //        // Check if we can create a single string or a new node
        //        if (itemType == DConstants.TYPE_STRING || itemType == DConstants.TYPE_BOOLEAN || itemType == DConstants.TYPE_NUMBER || itemType == DConstants.TYPE_INT || itemType == DConstants.TYPE_UINT || itemType == DConstants.TYPE_FUNCTION)
        //        {
        //            // Parse the text
        //            nodeXML = new XML("<node/>");
        //            nodeXML.@icon           = itemIcon;
        //            nodeXML.@label          = itemName + " (" + itemType + ") = " + printValue(item, itemType, true); 
        //            nodeXML.@name           = itemName;
        //            nodeXML.@type           = itemType; 
        //            nodeXML.@value          = printValue(item, itemType); 
        //            nodeXML.@target         = itemTarget;
        //            nodeXML.@access         = itemAccess;
        //            nodeXML.@permission     = itemPermission;
        //            rootXML.appendChild(nodeXML);
        //        }
        //        else
        //        {
        //            nodeXML = new XML("<node/>");
        //            nodeXML.@icon           = itemIcon;
        //            nodeXML.@label          = itemName + " (" + itemType + ")"; 
        //            nodeXML.@name           = itemName;
        //            nodeXML.@type           = itemType; 
        //            nodeXML.@target         = itemTarget;
        //            nodeXML.@access         = itemAccess;
        //            nodeXML.@permission     = itemPermission;

        //            // Check for null object
        //            if (item == null) {
        //                nodeXML.@icon = DConstants.ICON_WARNING;
        //                nodeXML.@label += " = null";
        //            }

        //            // Parse subchild
        //            nodeXML.appendChild(parse(item, itemTarget, currentDepth + 1, maxDepth, includeDisplayObjects).children());

        //            // Add to parent
        //            rootXML.appendChild(nodeXML);
        //        }
        //    }

        //    // Return
        //    return rootXML;
        //}


        ///**
        // * Get the functions of an object.
        // * @param object: The object to parse
        // * @param target: A point seperated path to the object
        // */
        //public static function parseFunctions(object:*, target:String = ""):XML
        //{
        //    // The return string
        //    var rootXML:XML = new XML("<root/>");

        //    // Get the descriptor
        //    var description:XML = DDescribeType.get(object);
        //    var type:String = parseType(description.@name);
        //    var itemXML:XML;
        //    var itemType:String = "";
        //    var itemName:String = "";
        //    var itemTarget:String = "";
        //    var key:String;
        //    var keys:Object = {};
        //    var methods:XMLList = description..method;
        //    var methodsArr:Array = [];
        //    var methodsLength:int = methods.length();
        //    var returnType:String;
        //    var parameters:XMLList;
        //    var parametersLength:int;
        //    var args:Array;
        //    var argsString:String;
        //    var optional:Boolean = false;
        //    var i:int = 0;
        //    var n:int = 0;

        //    // Create the head node
        //    itemXML = new XML("<node/>");
        //    itemXML.@icon = DConstants.ICON_DEFAULT;
        //    itemXML.@label = "(" + type + ")";
        //    itemXML.@target = target;

        //    // Save the methods
        //    // Filter out the doubles
        //    for (i = 0; i < methodsLength; i++) {
        //        key = methods[i].@name;
        //        try {
        //            if (!keys.hasOwnProperty(key)) {
        //                keys[key] = key;
        //                methodsArr[methodsArr.length] = {
        //                    name:       key,
        //                    xml:        methods[i],
        //                    access:     DConstants.ACCESS_METHOD
        //                };
        //            }
        //        } catch (e:Error) {
        //            //
        //        }
        //    }

        //    // Sort the nodes
        //    methodsArr.sortOn("name", Array.CASEINSENSITIVE);
        //    methodsLength = methodsArr.length;

        //    // Loop through the methods
        //    for (i = 0; i < methodsLength; i++)
        //    {
        //        // Save the type
        //        // Save the function info
        //        // Parameters, arguments, return type, etc
        //        itemType            = DConstants.TYPE_FUNCTION;
        //        itemName            = methodsArr[i].xml.@name;
        //        itemTarget          = target + DConstants.DELIMITER + itemName;
        //        returnType          = parseType(methodsArr[i].xml.@returnType);
        //        parameters          = methodsArr[i].xml..parameter;
        //        parametersLength    = parameters.length();
        //        args                = [];
        //        argsString          = "";
        //        optional            = false;

        //        // Create the parameters
        //        for (n = 0; n < parametersLength; n++)
        //        {
        //            // Optional parameters should start with a bracket
        //            if (parameters[n].@optional == "true" && !optional){
        //                optional = true;
        //                args[args.length] = "[";
        //            }

        //            // Push the parameter
        //            args[args.length] = parseType(parameters[n].@type);
        //        }

        //        // The optional bracket is needed
        //        if (optional) {
        //            args[args.length] = "]";
        //        }

        //        // Create the arguments string
        //        argsString = args.join(", ");
        //        argsString = argsString.replace("[, ", "[");
        //        argsString = argsString.replace(", ]", "]");

        //        // Create the node
        //        var methodXML:XML = new XML("<node/>");
        //        methodXML.@icon         = DConstants.ICON_FUNCTION;
        //        methodXML.@type         = DConstants.TYPE_FUNCTION;
        //        methodXML.@access       = DConstants.ACCESS_METHOD;
        //        methodXML.@label        = itemName + "(" + argsString + "):" + returnType;
        //        methodXML.@name         = itemName;
        //        methodXML.@target       = itemTarget;
        //        methodXML.@args         = argsString;
        //        methodXML.@returnType   = returnType;               

        //        // Loop through the parameters
        //        for (n = 0; n < parametersLength; n++)
        //        {
        //            // Create the parameters node
        //            var parameterXML:XML = new XML("<node/>");
        //            parameterXML.@type          = parseType(parameters[n].@type);
        //            parameterXML.@index         = parameters[n].@index;
        //            parameterXML.@optional      = parameters[n].@optional;
        //            methodXML.appendChild(parameterXML);
        //        }

        //        // Add to parent
        //        itemXML.appendChild(methodXML);
        //    }

        //    // Add to parent
        //    rootXML.appendChild(itemXML);

        //    // Return the xml
        //    return rootXML;
        //}


        //public static function parseType(type:String):String
        //{
        //    // Remove the package information
        //    if (type.indexOf("::") != -1) {
        //        type = type.substring(type.indexOf("::") + 2, type.length);
        //    }

        //    // Remove the vector information
        //    if (type.indexOf("::") != -1) {
        //        var part1:String = type.substring(0, type.indexOf("<") + 1);
        //        var part2:String = type.substring(type.indexOf("::") + 2, type.length);
        //        type = part1 + part2;
        //    }

        //    // Replace ()
        //    type = type.replace("()", "");

        //    // Check for the value "MethodClosure"
        //    type = type.replace(DConstants.TYPE_METHOD, DConstants.TYPE_FUNCTION);

        //    // Return the value
        //    return type;
        //}


        ///**
        // * Check if an object is a drawable displayobject.
        // * @param object: The object to check
        // */
        //public static function isDisplayObject(object:*):Boolean
        //{
        //    return (object is DisplayObject || object is DisplayObjectContainer);
        //}


        ///**
        // * Print an object value.
        // * @param value: The value to print
        // * @param type: The object type
        // * @param limit: Limit the output length to 140 chars
        // */
        //public static function printValue(value:*, type:String, limit:Boolean = false):String
        //{
        //    // We dont want to send the complete byte array
        //    // Only display the number of bytes
        //    if (type == DConstants.TYPE_BYTEARRAY) {
        //        return value["length"] + " bytes";
        //    }

        //    // Return null value
        //    if (value == null) {
        //        return "null";
        //    }

        //    // Return the string value
        //    var v:String = String(value);
        //    if (limit && v.length > 140) {
        //        v = v.substr(0, 140) + "...";
        //    }
        //    return v;
        //}

        //static public var ctrlKeyPress:Boolean;
        ///**
        // * Get object under point
        // */
        //public static function getObjectUnderPoint(container:DisplayObjectContainer, point:Point,deepMode:Boolean =false):DisplayObject
        //{
        //    // Properties
        //    var objects:Array;
        //    var object:DisplayObject;

        //    // Check for inaccessible objects
        //    if (container.areInaccessibleObjectsUnderPoint(point)) {
        //        return container;
        //    }

        //    // Get objects under point
        //    objects = container.getObjectsUnderPoint(point);
        //    objects.reverse();
        //    if (objects == null || objects.length == 0) {
        //        return container;
        //    }

        //    // Get top object
        //    object = objects[0];

        //    if (deepMode) {
        //        //if ctrl press,find textField only.
        //        if (!ctrlKeyPress) {
        //            for (var j:int = 0; j < objects.length; j++) 
        //            {
        //                object = objects[j];
        //                if (object is TextField || object is StaticText) {
        //                    return object;
        //                }
        //            }
        //            object = objects[0];
        //        }
        //        var p:DisplayObject = object.parent
        //        while(p != null){
        //            if (p is Hy.Image) {
        //                return p
        //            }
        //            if (p is Hy.MovieClipButton) {
        //                return p
        //            }
        //            p = p.parent;
        //        }

        //        return object;
        //    }

        //    objects.length = 0;

        //    // Save path to stage
        //    while (true) {
        //        objects[objects.length] = object;
        //        if (object.parent == null) {
        //            break;
        //        }
        //        object = object.parent;
        //    }

        //    // Set lowest first
        //    objects.reverse();

        //    // Go to the top and check for mouseEnabled items
        //    // and displayobject containers
        //    for (var i:int = 0; i < objects.length; i++) {
        //        var o:DisplayObject = objects[i];
        //        if (o is DisplayObjectContainer) {
        //            object = o;
        //            if (!DisplayObjectContainer(o).mouseChildren) {
        //                break;
        //            }
        //        } else {
        //            break;
        //        }
        //    }

        //    // Return found object
        //    return object;
        //}
    }
}
