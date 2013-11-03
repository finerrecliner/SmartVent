package com.example.smartvent;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class RoomAdapter extends ArrayAdapter<Room> {


	// declaring our ArrayList of items
	private ArrayList<Room> objects;

	/* here we must override the constructor for ArrayAdapter
	 * the only variable we care about now is ArrayList<Item> objects,
	 * because it is the list of objects we want to display.
	 */
	public RoomAdapter(Context context, int textViewResourceId, ArrayList<Room> objects) {
		super(context, textViewResourceId, objects);
		this.objects = objects;
	}

	/*
	 * we are overriding the getView method here - this is what defines how each
	 * list item will look.
	 */
	public View getView(int position, View convertView, ViewGroup parent){

		// assign the view we are converting to a local variable
		View v = convertView;

		// first check to see if the view is null. if so, we have to inflate it.
		// to inflate it basically means to render, or show, the view.
		if (v == null) {
			LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			v = inflater.inflate(R.layout.quick_room, null);
		}

		/*
		 * Recall that the variable position is sent in as an argument to this method.
		 * The variable simply refers to the position of the current object in the list. (The ArrayAdapter
		 * iterates through the list we sent it)
		 * 
		 * Therefore, i refers to the current Item object.
		 */
		Room i = objects.get(position);

		if (i != null) {

			// This is how you obtain a reference to the TextViews.
			// These TextViews are created in the XML files we defined.

			ImageView iconView = (ImageView) v.findViewById(R.id.icon);
			TextView roomName = (TextView) v.findViewById(R.id.quick_room_name);
			TextView currentTemp = (TextView) v.findViewById(R.id.quick_current_temp);

			// check to see if each individual view is null.
			// if not, assign something
			if (iconView != null){
				iconView.setImageResource(android.R.drawable.ic_menu_gallery);
			}
			if (roomName != null){
				roomName.setText(i.getName());
			}
			if (currentTemp != null){
				currentTemp.setText(i.getCurrentTemp().toString());
			}
		}

		// the view must be returned to our activity
		return v;

	}

}
