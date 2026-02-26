package com.sena.test.IService.IBillService;

import java.util.List;
import com.sena.test.Dto.BillDto.BillDetailsDto;
import com.sena.test.Entity.Bill.BillDetails;

public interface IBillDetailsService {

    public List<BillDetails>findAll();
    public BillDetails findById(int id);
    String update(int id, BillDetailsDto BillDetailsDto);
    public List<BillDetails> filterByQuantity(int quantity);
    public String save(BillDetailsDto p);
    public String delete(int id);
}