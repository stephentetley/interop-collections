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

namespace Interop {

    ///
    /// Represents a Java Iterator.
    ///
    pub enum RawIterator[_a: Type, _r: Region](##java.util.Iterator)


}

namespace Interop/RawIterator {

    use Interop.RawIterator;
    use Interop.RawIterator.{RawIterator};
    use Interop.Marshal;


    pub def getRawIterator(iter: RawIterator[a, r]): ##java.util.Iterator = 
        let RawIterator(iter1) = iter;
        iter1

    pub def new(_: Region[r], iter: ##java.util.Iterator): RawIterator[a, r] \ Write(r) = RawIterator(iter) as \Write(r)


    pub def iterator(iter: RawIterator[a, r]): Iterator[a, r] with Marshal[a]  =
        import java.util.Iterator.hasNext(): Bool & r;
        import java.util.Iterator.next(): ##java.lang.Object & r;
        let RawIterator(iter1) = iter;
        let isDone = () -> { 
            let ans = hasNext(iter1);
            not ans
        };
        let getNext = () -> {
            let a1 = next(iter1);
            Interop/Marshal.fromJavaObject(a1)
        };
        Iterator(isDone, getNext)
        
}
