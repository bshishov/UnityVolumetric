using UnityEngine;

namespace Assets.Util
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class DepthDebug : MonoBehaviour
    {
        public Shader DepthShader;
        [Range(0f, 1f)]
        public float From = 0f;

        [Range(0f, 1f)]
        public float To = 1f;

        private Material _mat;
        
        void Start ()
        {
		    _mat = new Material(DepthShader);
        }

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            _mat.SetFloat("_From", From);
            _mat.SetFloat("_To", To); 
            Graphics.Blit(src, dest, _mat);
        }
    }
}
