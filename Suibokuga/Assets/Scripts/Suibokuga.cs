using UnityEngine;
using System.Collections;
 
using Utils;

[RequireComponent (typeof (Camera) ) ]
public class Suibokuga : MonoBehaviour {

	[SerializeField] Shader shader;
	Material mat;

	[SerializeField] Texture2D paper;
	[SerializeField, Range(0f, 1f)] float alpha = 1.0f;
	[SerializeField, Range(0f, 0.005f)] float evaporation = 0.0001f;

	[SerializeField, Range(0, 10)] int iterations = 4;
	[SerializeField] int size = 1024;

	FboPingPong fpp;

	bool dragging = false;
	Vector2 previous;

	void Start () {
		fpp = new FboPingPong(size, size);
		mat = new Material(shader);

		mat.SetTexture("_PaperTex", paper);

		Init();
	}
	
	void Update () {

		Vector3 mousePos = Input.mousePosition;
		Vector2 current = new Vector2(mousePos.x / Screen.width, mousePos.y / Screen.height);
		mat.SetVector("_Prev", previous);

		if(dragging) {
			mat.SetVector("_Brush", new Vector3(current.x, current.y, 0.015f));
		} else {
			mat.SetVector("_Brush", new Vector3(0, 0, 0));
		}

		if(Input.GetMouseButtonDown(0)) {
			dragging = true;
		} else if(Input.GetMouseButtonUp(0)) {
			dragging = false;
		}

		previous = current;

		mat.SetFloat("_Alpha", alpha);
		mat.SetFloat("_Evaporation", evaporation);

		for(int i = 0; i < iterations; i++) {
			Graphics.Blit(fpp.GetReadTex(), fpp.GetWriteTex(), mat, 1); // update
			fpp.Swap();
		}
	}

	void Init () {
		Graphics.Blit(fpp.GetReadTex(), fpp.GetWriteTex(), mat, 0); // init
		fpp.Swap();
	}

	void OnRenderImage (RenderTexture src, RenderTexture dst) {
		Graphics.Blit(fpp.GetReadTex(), dst, mat, 2);
	}

	void OnGUI () {
		const float offset = 10;
		if(GUI.Button(new Rect(offset, offset, 100, 30), "Reset")) {
			Init();
		}
	}

}
