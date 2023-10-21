class Node {
  int node_id;
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;
  Vec3 init_pos;
  String type;
  Vec3 air_drag_a;
  Node(Vec3 pos, String type, int node_id) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = pos;
    this.type = type;
    this.node_id = node_id;
    this.init_pos = pos;
    this.air_drag_a = new Vec3(0, 0, 0);
  }
  public void reset(){
    this.pos = init_pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = init_pos;
  }
}
