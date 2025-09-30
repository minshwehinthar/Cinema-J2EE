package com.demo.model;

import java.sql.Time;

public class Timeslot {

    private int slotId;
    private int theaterId;
    private Time startTime;
    private Time endTime;

    // Constructors
    public Timeslot() { }

    public Timeslot(int slotId, int theaterId, Time startTime, Time endTime) {
        this.slotId = slotId;
        this.theaterId = theaterId;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    // Getters and Setters
    public int getSlotId() {
        return slotId;
    }

    public void setSlotId(int slotId) {
        this.slotId = slotId;
    }

    public int getTheaterId() {
        return theaterId;
    }

    public void setTheaterId(int theaterId) {
        this.theaterId = theaterId;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }
}
