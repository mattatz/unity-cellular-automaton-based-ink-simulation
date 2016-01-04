using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Utils {
	public class FboPingPong {

		private int _readTex  = 0;
		private int _writeTex = 1;
		private RenderTexture[] _buffer;

		/// <summary>
		/// Init the specified width_ and height_.
		/// </summary>
		/// <param name="width_">Width_.</param>
		/// <param name="height_">Height_.</param>
		public FboPingPong (int width_, int height_, FilterMode filterMode = FilterMode.Point, TextureWrapMode wrapMode = TextureWrapMode.Repeat){

			_readTex  = 0;
			_writeTex = 1;

			_buffer = new RenderTexture [2];

			for (int i = 0; i < 2; i++){
				_buffer [i] = new RenderTexture (width_, height_, 0, RenderTextureFormat.ARGBFloat);
				_buffer [i].hideFlags  = HideFlags.DontSave;
				_buffer [i].filterMode = filterMode;
				_buffer [i].wrapMode   = wrapMode;
				_buffer [i].Create ();
			}

			Clear ();
		}

		/// <summary>
		/// Swap buffers.
		/// </summary>
		public void Swap (){
			//RenderTexture temp = _buffer[0];
			//_buffer [0] = _buffer [1];
			//_buffer [1] = temp;
			int t     = _readTex;
			_readTex  = _writeTex;
			_writeTex = t;
		}

		/// <summary>
		/// Clear buffers.
		/// </summary>
		public void Clear (){
			for (int i = 0; i < _buffer.Length; i++){
				RenderTexture.active = _buffer [i];
				GL.Clear (false, true, Color.black);
				RenderTexture.active = null;
			}
		}

		/// <summary>
		/// Delete buffers.
		/// </summary>
		public void Delete (){
			if (_buffer != null) {
				for (int i = 0; i < _buffer.Length; i++){
					_buffer[i].Release ();
					_buffer[i].DiscardContents ();
					_buffer[i] = null;
				}
			}
		}

		/// <summary>
		/// Gets the read tex.
		/// </summary>
		/// <returns>The read tex.</returns>
		public RenderTexture GetReadTex (){
			return _buffer [_readTex];	
		}

		/// <summary>
		/// Gets the write tex.
		/// </summary>
		/// <returns>The write tex.</returns>
		public RenderTexture GetWriteTex (){
			return _buffer [_writeTex];
		}

	}

}


