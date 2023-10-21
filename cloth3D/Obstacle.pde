class Obstacle {
  int obstacle_id;
  float radius;
  Vec3 pos;
  String obstacle_type;
  Obstacle(Vec3 pos, float radius, String obstacle_type, int obstacle_id) {
    this.pos = pos;
    this.obstacle_type = obstacle_type;
    this.obstacle_id = obstacle_id;
    this.radius = radius;
  }
}
