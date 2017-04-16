using UnityEditor;
using UnityEngine;

namespace Assets.Util
{
    [RequireComponent(typeof(MeshRenderer))]
    public class Tex3DLoader : MonoBehaviour
    {
        public Texture2D[] Slices;


        void Start()
        {
            var size = 16;
            var tex = new Texture3D(size, size, size, TextureFormat.ARGB32, true);
            var cols = new Color[size * size * size];
            float mul = 1.0f / (size - 1);
            int idx = 0;
            Color c = Color.white;

            var x1 = 0;
            var y1 = 0;
            var z1 = 0;

            for (int z = 0; z < size; ++z)
            {
                for (int y = 0; y < size; ++y)
                {
                    for (int x = 0; x < size; ++x, ++idx)
                    {
                        c.r = ((x1) != 0) ? x * mul : 1 - x * mul;
                        c.g = ((y1) != 0) ? y * mul : 1 - y * mul;
                        c.b = ((z1) != 0) ? z * mul : 1 - z * mul;
                        cols[idx] = c;
                    }
                }
            }
            tex.SetPixels(cols);
            tex.Apply();
            GetComponent<MeshRenderer>().material.SetTexture("_Volume", tex);
        }

        public void Set()
        {
            
            if(Slices.Length == 0)
                return;

            var first = Slices[0];
            var w = first.width;
            var h = first.height;
            var d = Slices.Length;

            var idx = 0;
            var buffer = new Color32[w*h*d];
            var tex = new Texture3D(w, h, d, TextureFormat.ARGB32, false) {filterMode = FilterMode.Trilinear};

            for (var z = 0; z < d; z++)
            {

                for (var x = 0; x < w; x++)
                {
                    for (var y = 0; y < h; y++)
                    {
                    
                        buffer[idx++] = Slices[z].GetPixel(x, y);
                    }
                }
            }

            tex.SetPixels32(buffer);

            var meshRenderer = GetComponent<MeshRenderer>();
            if (meshRenderer == null)
            {
                Debug.LogWarning("No mesh renderer found.");
                return;
            }

            meshRenderer.material.SetTexture("_Volume", tex);
        }
    }
    
    [CustomEditor(typeof(Tex3DLoader))]
    public class Tex3DLoaderEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();

            var loader = (Tex3DLoader)target;
            if (GUILayout.Button("Set to material"))
            {
                loader.Set();
            }
        }
    }
}
