package com.example.smartvent;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

public class MainActivity extends Activity implements OnItemClickListener {

	private static final int EDIT_REQUEST = 1000;
	
	private ArrayList<Room> rooms = new ArrayList<Room>();
	private RoomAdapter adapter;
	private List<ScheduledExecutorService> scheduleTaskExecutors = new ArrayList<ScheduledExecutorService>();

	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (savedInstanceState == null) {
        	rooms.add(new Room(0, "Kitchen"));
        	rooms.add(new Room(1, "Conference Room"));
        	rooms.add(new Room(2, "Living Room "));
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
        
        for (final Room r : rooms)
        {
        	scheduleTaskExecutors.add(Executors.newSingleThreadScheduledExecutor());
        	scheduleTaskExecutors.get(r.getId()).scheduleAtFixedRate(new Runnable() {
        		public void run() {

        			/* Read current status */

        			// Create a new HttpClient and Post Header
        			HttpClient httpclient = new DefaultHttpClient();
        			HttpPost httppost = new HttpPost("http://www.obycode.com/smartventure/query.php");

        			try {
        				// Add data
        				List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
        				nameValuePairs.add(new BasicNameValuePair("room", r.getName()));
        				httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

        				// Execute HTTP Post Request
        				HttpResponse response = httpclient.execute(httppost);
        				BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent(), "UTF-8"));
        				String jsonStr = reader.readLine();
        				JSONObject jsonObj = new JSONObject(jsonStr);

        				//Log.i(getString(R.string.app_name), jsonObj.toString());
        				r.setCurrentTemp(Integer.parseInt((String)jsonObj.get("temp")));
        				//Log.i(getString(R.string.app_name), r.getCurrentTemp().toString());			        
        				r.setVentState(Integer.parseInt((String)jsonObj.get("state")));
        				//Log.i(getString(R.string.app_name), r.getVentState().toString());

        			} catch (ClientProtocolException e) {
        				Toast.makeText(getBaseContext(), "ClientProtocol Error", Toast.LENGTH_SHORT).show();
        				Log.e(getString(R.string.app_name), "ClientProtocol Error");
        			} catch (IOException e) {
        				Toast.makeText(getBaseContext(), "IO HTTP Error", Toast.LENGTH_SHORT).show();
        				Log.e(getString(R.string.app_name), "IO HTTP Error");
        			} catch (JSONException e) {
        				Toast.makeText(getBaseContext(), "JSON Error", Toast.LENGTH_SHORT).show();
        				Log.e(getString(R.string.app_name), "JSON Error");
        			}

        			runOnUiThread(new Runnable() {
        				public void run() {
        					adapter.notifyDataSetChanged();
        				}
        			});


        			/* Set new vent state */

        			// Create a new HttpClient and Post Header
        			httpclient = new DefaultHttpClient();
        			httppost = new HttpPost("http://www.obycode.com/smartventure/set.php");

        			try {
        				// Add your data
        				List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
        				nameValuePairs.add(new BasicNameValuePair("room", r.getName()));
        				nameValuePairs.add(new BasicNameValuePair("setpoint",  RoomActivity.updateCoolingVent(r.getCurrentTemp(), r.getTargetTemp(), r.getVentState()).toString()));
        				httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

        				// Execute HTTP Post Request
        				HttpResponse response = httpclient.execute(httppost);

        			} catch (ClientProtocolException e) {
        				Toast.makeText(getBaseContext(), "ClientProtocol Error", Toast.LENGTH_SHORT).show();
        			} catch (IOException e) {
        				Toast.makeText(getBaseContext(), "IO HTTP Error", Toast.LENGTH_SHORT).show();
        			}
        		}
        	}, 0, 5, TimeUnit.SECONDS);
        }        
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }
    
    @Override
    protected void onDestroy() {
    	// kill scheduled Task Executors
    	for (ScheduledExecutorService s : scheduleTaskExecutors) {
        	s.shutdown();			
		}
    	super.onDestroy();
    };


	@Override
	public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {
		// explicit intent
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
    				// add updated Room to list
    		        Room newRoom= data.getParcelableExtra(getString(R.string.room));
    		        rooms.remove(newRoom.getId());
    		        rooms.add(newRoom.getId(), newRoom);
    		        
    		        
    		        adapter.notifyDataSetChanged();
    		default:
    			super.onActivityResult(requestCode, resultCode, data);
    			break;
    	}
    }
    
}
