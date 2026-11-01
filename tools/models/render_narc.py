import bpy, math, os, sys
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
obj_path, co_path, nohq_path, out_path = argv[:4]
views = argv[4] if len(argv) > 4 else "icon"

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.wm.obj_import(filepath=obj_path)
ob = bpy.context.selected_objects[0]
for p in ob.data.polygons:
    p.use_smooth = True

mat = bpy.data.materials.new("narc")
mat.use_nodes = True
nt = mat.node_tree
bsdf = nt.nodes["Principled BSDF"]
tex = nt.nodes.new("ShaderNodeTexImage")
tex.image = bpy.data.images.load(co_path)
nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
ntex = nt.nodes.new("ShaderNodeTexImage")
ntex.image = bpy.data.images.load(nohq_path)
ntex.image.colorspace_settings.name = "Non-Color"
nmap = nt.nodes.new("ShaderNodeNormalMap")
nt.links.new(ntex.outputs["Color"], nmap.inputs["Color"])
nt.links.new(nmap.outputs["Normal"], bsdf.inputs["Normal"])
bsdf.inputs["Roughness"].default_value = 0.42
ob.data.materials.clear()
ob.data.materials.append(mat)

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.film_transparent = True
scene.render.resolution_x = scene.render.resolution_y = 1024

world = bpy.data.worlds.new("w")
scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.55, 0.57, 0.6, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.25


def light(name, loc, energy, size=0.3):
    l = bpy.data.lights.new(name, "AREA")
    l.energy = energy
    l.size = size
    o = bpy.data.objects.new(name, l)
    o.location = loc
    d = Vector((0, 0, 0.05)) - Vector(loc)
    o.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
    scene.collection.objects.link(o)


light("key", (0.5, 0.6, 0.7), 30)
light("fill", (-0.7, 0.4, 0.3), 8)
light("rim", (-0.2, -0.8, 0.6), 30)

cam = bpy.data.cameras.new("cam")
cam.lens = 85
co = bpy.data.objects.new("cam", cam)
scene.collection.objects.link(co)
scene.camera = co

# the obj import turns it back to the file's axes: front is +y
shots = {
    "icon": (0.55, 0.62, 0.42),
    "front": (0.0, 0.9, 0.25),
    "back": (-0.45, -0.75, 0.35),
    "side": (-0.85, 0.2, 0.2),
    "top": (0.05, 0.25, 0.9),
    "low": (0.6, 0.5, 0.06),
}
target = Vector((0, 0, 0.05))
for name in views.split(","):
    co.location = shots[name]
    co.rotation_euler = (target - Vector(shots[name])).to_track_quat("-Z", "Y").to_euler()
    # frame the case
    bpy.context.view_layer.update()
    cam.lens = 85 if name != "icon" else 95
    scene.render.filepath = out_path.replace("%s", name)
    bpy.ops.render.render(write_still=True)
