package com.sena.test.Dto.BillDto;

import java.time.LocalDate;

public class BillDto {
    private int id;
    private LocalDate date;
    private double total;

    public BillDto(int id, LocalDate date, double total) {
        this.id = id;
        this.date = date;
        this.total = total;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }
}