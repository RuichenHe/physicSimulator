//---------------
//Vec 3 Library
//---------------

//3D Vector Library
// Ruichen He <he000239@umn.edu>

public class Vec3 {
  public float x, y, z;

  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public String toString() {
    return "(" + x + "," + y  + "," + z + ")";
  }
  
  public float length() {
    return sqrt(x * x + y * y + z * z);
  }
  
  public float lengthSqr() {
    return x * x + y * y + z * z;
  }
  
  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
  }
  
  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
  }
  
  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }
  
  public Vec3 times(float rhs) {
    return new Vec3(x * rhs, y * rhs, z * rhs);
  }
  
  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }
  
  public void clampToLength(float maxL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
      z *= maxL / magnitude;
    }
  }
  
  public void setToLength(float newL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    x *= newL / magnitude;
    y *= newL / magnitude;
    z *= newL / magnitude;
  }
  
  public void normalize() {
    float magnitude = sqrt(x * x + y * y + z * z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }
  
  public Vec3 normalized() {
    float magnitude = sqrt(x * x + y * y + z * z);
    return new Vec3(x / magnitude, y / magnitude, z / magnitude);
  }
  
  public float distanceTo(Vec3 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

float dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
Vec3 product(Vec3 a, Vec3 b){
  return new Vec3(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x);
}
Vec3 closestPoint(Vec3 p1, Vec3 p2, Vec3 a){
  Vec3 p1p2 = p2.minus(p1);
  Vec3 dir_p1p2 = p1p2.normalized();
  float length_p1p2 = p1p2.length();
  
  Vec3 p1A = a.minus(p1);
  float v = dot(dir_p1p2, p1A)/length_p1p2;
  Vec3 closestPoint;
  if (v <= 0){
    closestPoint = p1;
  } else if (v >= 1){
    closestPoint = p2;
  } else {
    closestPoint = p1.plus(dir_p1p2.times(v * length_p1p2));
  }
  return closestPoint;
}
