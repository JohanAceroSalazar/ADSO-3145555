package com.sena.test.IService.IBillService;

import java.sql.Date;
import java.util.List;
import com.sena.test.Dto.BillDto.BillDto;
import com.sena.test.Entity.Bill.Bill;

public interface IBillService {

    public List<Bill>findAll();
    public Bill findById(int id);
    String update(int id, BillDto BillDto);
    public List<Bill> filterByDate(Date date);
    public String save(BillDto b);
    public String delete(int id);
}