using UnityEngine;

namespace Assets.Util
{
    public class Rotator : MonoBehaviour
    {
        public Vector3 RotationAmount = Vector3.zero;
	
        void Update ()
        {
		    transform.Rotate(RotationAmount);
        }
    }
}
