@test
def test01(): Unit & Impure = 
    import static java.lang.System.getenv(): ##java.util.Map & Impure;
    use Interop/Collections.RawMap;
    use Interop/Collections.RawMap.{RawMap};
    let raw: RawMap[String, String, Static] = RawMap(getenv());
    let flixm = Interop/Collections/RawMap.toMap(raw);
    Map.foreach((k, v) -> println("${k} => ${v}"), flixm);
    ()
    