package com.example.smartvent;

import android.os.Parcel;
import android.os.Parcelable;

public class Room implements Parcelable {

	private String name;
	private Integer currentTemp;
	private Integer targetTemp;
	private Integer ventState;
	
	public Room(String name) {
		this.name = name;
		this.currentTemp = 70;
		this.targetTemp = 70;
		this.ventState = 0;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getCurrentTemp() {
		return currentTemp;
	}
	public void setCurrentTemp(Integer currentTemp) {
		this.currentTemp = currentTemp;
	}
	public Integer getTargetTemp() {
		return targetTemp;
	}
	public void setTargetTemp(Integer targetTemp) {
		this.targetTemp = targetTemp;
	}
	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(name);
		dest.writeInt(currentTemp);
		dest.writeInt(targetTemp);
		dest.writeInt(ventState);
	}
	
	public static Parcelable.Creator<Room> CREATOR = new Creator<Room>() {
		@Override public Room[] newArray(int size) {
			return new Room[size];
		}
		
		// create a new Person object from an intent Parcel
		@Override public Room createFromParcel(Parcel source) {
			Room r = new Room(source.readString());
			r.setCurrentTemp(source.readInt());
			r.setTargetTemp(source.readInt());
			r.setVentState(source.readInt());
			return r;
		}
	};

	public void incTargetTemp() {
		this.targetTemp++;
	}
	public void decTargetTemp() {
		this.targetTemp--;
	}
	public Integer getVentState() {
		return ventState;
	}
	public void setVentState(Integer ventState) {
		this.ventState = ventState;
	}
	
}
