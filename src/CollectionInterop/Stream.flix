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

namespace CollectionInterop {

    ///
    /// Represents a Java Stream.
    ///
    pub enum RawStream[_a: Type, _r: Region](##java.util.stream.Stream)

    ///
    /// Represents a Java IntStream.
    ///
    pub enum IntStream[_r: Region](##java.util.stream.IntStream)

    instance Scoped[IntStream] {
        pub def regionOf(_: IntStream[r]): Region[r] = () as Region[r]
    }

    ///
    /// Represents a Java LongStream.
    ///
    pub enum LongStream[_r: Region](##java.util.stream.LongStream)

    instance Scoped[LongStream] {
        pub def regionOf(_: LongStream[r]): Region[r] = () as Region[r]
    }

    ///
    /// Represents a Java DoubleStream.
    ///
    pub enum DoubleStream[_r: Region](##java.util.stream.DoubleStream)

    instance Scoped[DoubleStream] {
        pub def regionOf(_: DoubleStream[r]): Region[r] = () as Region[r]
    }

}


namespace CollectionInterop/Stream {
    
    use CollectionInterop.RawStream;
    use CollectionInterop.RawStream.{RawStream};
    use CollectionInterop.IntStream;
    use CollectionInterop.IntStream.{IntStream};
    use CollectionInterop.LongStream;
    use CollectionInterop.LongStream.{LongStream};
    use CollectionInterop.DoubleStream;
    use CollectionInterop.DoubleStream.{DoubleStream};
    

    use CollectionInterop.Marshal;

    pub def new(_: Region[r], prim: ##java.util.stream.Stream): RawStream[a, r] = RawStream(prim)

    pub def iterator(s: RawStream[a, r]): Iterator[a, r] \ Write(r) with Marshal[a] =
        iteratorWith(CollectionInterop/Marshal.fromJavaObject, s)

    pub def iteratorWith(ocast: ##java.lang.Object -> a, s: RawStream[a, r]): Iterator[a, r] \ Write(r) with Marshal[a] =
        import java.util.stream.BaseStream.iterator(): ##java.util.Iterator & r;
        import java.util.Iterator.hasNext(): Bool & r;
        import java.util.Iterator.next(): ##java.lang.Object & r;
        let RawStream(s1) = s;       
        let iter1 = iterator(s1 as ##java.util.stream.BaseStream);
        let isDone = () -> { 
            let ans = hasNext(iter1);
            not ans
        };
        let getNext = () -> {
            let a1 = next(iter1);
            ocast(a1)
        };
        Iterator(isDone, getNext)


    pub def newIntStream(_: Region[r], prim: ##java.util.stream.IntStream): IntStream[r] = IntStream(prim)

    pub def intStreamIterator(s: IntStream[r]): Iterator[Int32, r] \ Write(r) =
        import java.util.stream.BaseStream.iterator(): ##java.util.Iterator & r;
        let r = Scoped.regionOf(s);
        let IntStream(s1) = s;
        let iter1 = iterator(s1 as ##java.util.stream.BaseStream);
        let iter2 = CollectionInterop/RawIterator.new(r, iter1);
        CollectionInterop/RawIterator.iterator(iter2)

    pub def newLongStream(_: Region[r], prim: ##java.util.stream.LongStream): LongStream[r] = LongStream(prim)

    pub def longStreamIterator(s: LongStream[r]): Iterator[Int64, r] \ Write(r) =
        import java.util.stream.BaseStream.iterator(): ##java.util.Iterator & r;
        let r = Scoped.regionOf(s);
        let LongStream(s1) = s;
        let iter1 = iterator(s1 as ##java.util.stream.BaseStream);
        let iter2 = CollectionInterop/RawIterator.new(r, iter1);
        CollectionInterop/RawIterator.iterator(iter2)

    pub def newDoubleStream(_: Region[r], prim: ##java.util.stream.DoubleStream): DoubleStream[r] = DoubleStream(prim)

    pub def doubleStreamIterator(s: DoubleStream[r]): Iterator[Float64, r] \ Write(r) =
        import java.util.stream.BaseStream.iterator(): ##java.util.Iterator & r;
        let r = Scoped.regionOf(s);
        let DoubleStream(s1) = s;
        let iter1 = iterator(s1 as ##java.util.stream.BaseStream);
        let iter2 = CollectionInterop/RawIterator.new(r, iter1);
        CollectionInterop/RawIterator.iterator(iter2)

}
