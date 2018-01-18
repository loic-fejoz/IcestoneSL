if Path == nil then
  Path = ""
end

dofile(Path .. "sd-icesl.lua")
obj = sdImplicit(
  v(-20, -20, -20),
  v(20, 20, 20),
  sdBlend(
    sdBlend(
      sdTorus(5, 3),
      sdTranslate(-5.5, 0, 0) *
        sdBox(3, 4, 5)),
    sdTranslate(7.5, 0, 0) *
      sdSphere(3)))
emit(rotate(0, -90, 0) * obj)