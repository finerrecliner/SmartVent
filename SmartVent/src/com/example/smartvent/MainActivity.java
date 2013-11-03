package com.example.smartvent;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

public class MainActivity extends Activity implements OnItemClickListener {

	private static final int EDIT_REQUEST = 1000;
	
	private ArrayList<Room> rooms = new ArrayList<Room>();
	private RoomAdapter adapter;
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState == null) {
        	Room kitchen = new Room("Kitchen");
        	Room conf = new Room("Conference Room");
        	Room living = new Room("Living Room");

        	rooms.add(kitchen);
        	rooms.add(conf);
        	rooms.add(living);
        }
        else
        {
        	// use saved contact list.
        	rooms = savedInstanceState.getParcelableArrayList("rooms");
        }

        // instantiate our ItemAdapter class
        adapter = new RoomAdapter(this, R.layout.quick_room, rooms);
        ListView allRoomsView = (ListView) findViewById(R.id.quick_room_list);
        allRoomsView.setAdapter(adapter);

        allRoomsView.setOnItemClickListener(this);
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {
		// implicit intent
		Intent intent = new Intent(this, RoomActivity.class);
		intent.putExtra(getString(R.string.room), rooms.get(pos));
		startActivityForResult(intent, EDIT_REQUEST);
	}
	
    @Override protected void onSaveInstanceState(Bundle outState) {
    	super.onSaveInstanceState(outState);
    	outState.putParcelableArrayList("rooms", rooms);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    	switch(requestCode) {
    		case EDIT_REQUEST:
    			switch (resultCode) {
    			case RESULT_OK:
    				// add updated Room to list
    		        Room newRoom= data.getParcelableExtra(getString(R.string.room));
    		        rooms.add((int) newRoom.getId(), newRoom);
    		        
    		        adapter.notifyDataSetChanged();
    		        
    				break;
    			case RESULT_CANCELED:
    				// User cancelled. Nothing to update.
    			default:
    				break;
    			}
    		default:
    			super.onActivityResult(requestCode, resultCode, data);
    			break;
    	}
    }
    
}
