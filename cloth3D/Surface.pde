class Surface {
  int surface_id;
  int node1_id;
  int node2_id;
  int node3_id;
  float u0;
  float v0;
  float u1;
  float v1;
  String surface_type;
  Surface(int surface_id, int node1_id, int node2_id, int node3_id, float u0, float v0, float u1, float v1, String surface_type) {
    this.surface_id = surface_id;
    this.node1_id = node1_id;
    this.node2_id = node2_id;
    this.node3_id = node3_id;
    this.u0 = u0;
    this.v0 = v0;
    this.u1 = u1;
    this.v1 = v1;
    this.surface_type = surface_type;
  }
}
