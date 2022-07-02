@test
def test01(): Unit & Impure = 
    import static java.lang.System.getenv(): ##java.util.Map & Impure;
    use Interop.RawMap;
    use Interop.RawMap.{RawMap};
    let raw: RawMap[String, String, Static] = RawMap(getenv());
    let flixm = Interop/RawMap.toMap(raw);
    Map.foreach((k, v) -> println("${k} => ${v}"), flixm);
    ()
    