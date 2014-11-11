#= require ext

Math.circleDistance = (p0, p1)->
  r = 3963.0
  lat1 = p0.lat().toRad()
  lon1 = p0.lng().toRad()
  lat2 = p1.lat().toRad()
  lon2 = p1.lng().toRad()

  return r * Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1))
