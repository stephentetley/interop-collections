/*
 * Copyright 2022 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace Interop/Collections {


    // TODO 
    // There is a good case for having a singleton method toJavaObject class
    // and a toJavaObject / fromJavaObject class. It is common to see enums
    // that are used as arguments but are never returned in Java API's


    pub class Marshal[a] {
        pub def toJavaObject(x: a): ##java.lang.Object

        pub def fromJavaObject(o: ##java.lang.Object): a
    }


    instance Marshal[String] {
        pub def toJavaObject(x: String): ##java.lang.Object = x as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): String = o as String
    }

    instance Marshal[Bool] {
        pub def toJavaObject(x: Bool): ##java.lang.Object = Interop/Collections/Marshal.marshalBool(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Bool = Interop/Collections/Marshal.unmarshalBool(o as ##java.lang.Boolean)
    }

    instance Marshal[Char] {
        pub def toJavaObject(x: Char): ##java.lang.Object = Interop/Collections/Marshal.marshalChar(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Char = Interop/Collections/Marshal.unmarshalChar(o as ##java.lang.Character)
    }

    instance Marshal[Int8] {
        pub def toJavaObject(x: Int8): ##java.lang.Object = Interop/Collections/Marshal.marshalInt8(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Int8 = Interop/Collections/Marshal.unmarshalInt8(o as ##java.lang.Byte)
    }

    instance Marshal[Int16] {
        pub def toJavaObject(x: Int16): ##java.lang.Object = Interop/Collections/Marshal.marshalInt16(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Int16 = Interop/Collections/Marshal.unmarshalInt16(o as ##java.lang.Short)
    }

    instance Marshal[Int32] {
        pub def toJavaObject(x: Int32): ##java.lang.Object = Interop/Collections/Marshal.marshalInt32(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Int32 = Interop/Collections/Marshal.unmarshalInt32(o as ##java.lang.Integer)
    }
    
    instance Marshal[Int64] {
        pub def toJavaObject(x: Int64): ##java.lang.Object = Interop/Collections/Marshal.marshalInt64(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Int64 = Interop/Collections/Marshal.unmarshalInt64(o as ##java.lang.Long)
    }

    instance Marshal[BigInt] {
        pub def toJavaObject(x: BigInt): ##java.lang.Object = x as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): BigInt = o as BigInt
    }

    instance Marshal[Float32] {
        pub def toJavaObject(x: Float32): ##java.lang.Object = Interop/Collections/Marshal.marshalFloat32(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Float32 = Interop/Collections/Marshal.unmarshalFloat32(o as ##java.lang.Float)
    }

    instance Marshal[Float64] {
        pub def toJavaObject(x: Float64): ##java.lang.Object = Interop/Collections/Marshal.marshalFloat64(x) as ##java.lang.Object
        pub def fromJavaObject(o: ##java.lang.Object): Float64 = Interop/Collections/Marshal.unmarshalFloat64(o as ##java.lang.Double)
    }

    instance Marshal[List[a]] with Marshal[a] {
        pub def toJavaObject(l: List[a]): ##java.lang.Object =
            region r1 {
                Interop/Collections/RawList.fromListViaArrayList(r1, l) as ##java.lang.Object
            } 
        
        pub def fromJavaObject(o: ##java.lang.Object): List[a] = 
            region r1 {
                Interop/Collections/RawList.new(r1, o as ##java.util.List) |> Interop/Collections/RawList.toList
            }
    }

    instance Marshal[Option[a]] with Marshal[a] {
        pub def toJavaObject(o: Option[a]): ##java.lang.Object =
            region r1 {
                Interop/Collections/Optional.fromOption(r1, o) as ##java.lang.Object
            } 
        
        pub def fromJavaObject(o: ##java.lang.Object): Option[a] = 
            region r1 {
                Interop/Collections/Optional.new(r1, o as ##java.util.Optional) |> Interop/Collections/Optional.toOption(r1)
            }
    }

}


namespace Interop/Collections/Marshal {


    pub def marshalBool(b: Bool): ##java.lang.Boolean = 
        import static java.lang.Boolean.valueOf(Bool): ##java.lang.Boolean & Pure;
        valueOf(b)

    pub def unmarshalBool(b: ##java.lang.Boolean): Bool = 
        import java.lang.Boolean.booleanValue(): Bool & Pure;
        booleanValue(b)

    pub def marshalChar(c: Char): ##java.lang.Character = 
        import static java.lang.Character.valueOf(Char): ##java.lang.Character & Pure;
        valueOf(c)

    pub def unmarshalChar(c: ##java.lang.Character): Char = 
        import java.lang.Character.charValue(): Char & Pure;
        charValue(c)


    pub def marshalInt8(i: Int8): ##java.lang.Byte = 
        import static java.lang.Byte.valueOf(Int8): ##java.lang.Byte & Pure;
        valueOf(i)

    pub def unmarshalInt8(i: ##java.lang.Byte): Int8 = 
        import java.lang.Byte.intValue(): Int8 & Pure;
        intValue(i)


    pub def marshalInt16(i: Int16): ##java.lang.Short = 
        import static java.lang.Short.valueOf(Int16): ##java.lang.Short & Pure;
        valueOf(i)

    pub def unmarshalInt16(i: ##java.lang.Short): Int16 = 
        import java.lang.Short.intValue(): Int16 & Pure;
        intValue(i)

    pub def marshalInt32(i: Int32): ##java.lang.Integer = 
        import static java.lang.Integer.valueOf(Int32): ##java.lang.Integer & Pure;
        valueOf(i)

    pub def unmarshalInt32(i: ##java.lang.Integer): Int32 = 
        import java.lang.Integer.intValue(): Int32 & Pure;
        intValue(i)

    pub def marshalInt64(i: Int64): ##java.lang.Long = 
        import static java.lang.Long.valueOf(Int64): ##java.lang.Long & Pure;
        valueOf(i)

    pub def unmarshalInt64(i: ##java.lang.Long): Int64 = 
        import java.lang.Long.intValue(): Int64 & Pure;
        intValue(i)


    pub def marshalFloat32(d: Float32): ##java.lang.Float = 
        import static java.lang.Float.valueOf(Float32): ##java.lang.Float & Pure;
        valueOf(d)

    pub def unmarshalFloat32(d: ##java.lang.Float): Float32 = 
        import java.lang.Float.floatValue(): Float32 & Pure;
        floatValue(d)

    pub def marshalFloat64(d: Float64): ##java.lang.Double = 
        import static java.lang.Double.valueOf(Float64): ##java.lang.Double & Pure;
        valueOf(d)

    pub def unmarshalFloat64(d: ##java.lang.Double): Float64 = 
        import java.lang.Double.doubleValue(): Float64 & Pure;
        doubleValue(d)

}
