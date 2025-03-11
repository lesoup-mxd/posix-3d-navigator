// This file manages the overall scene, including the addition and removal of objects, as well as the rendering process. 

class Scene {
    private:
        List<Object3D> objects;

    public:
        Scene() {
            objects = new List<Object3D>();
        }

        void addObject(Object3D object) {
            objects.add(object);
        }

        void removeObject(Object3D object) {
            objects.remove(object);
        }

        void render() {
            for (Object3D object : objects) {
                object.render();
            }
        }
}