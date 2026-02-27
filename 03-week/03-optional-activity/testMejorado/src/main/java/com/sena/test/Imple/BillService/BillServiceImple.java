package com.sena.test.Imple.BillService;

import java.sql.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.Dto.BillDto.BillDto;
import com.sena.test.Entity.Bill.Bill;
import com.sena.test.IRepository.IBillRepository.BillRepository;
import com.sena.test.IService.IBillService.IBillService;

@Service
public class BillServiceImple implements IBillService{

    @Autowired
    private BillRepository repo;

    @Override
    public List<Bill>findAll(){
        return repo.findAll();
    }

    @Override
    public Bill findById(int id){
        return repo.findById(id).orElse(null);
    }

    @Override
    public String update(int id, BillDto billDto){
        Bill bill = repo.findById(id).orElse(null);

        if(bill == null){
            return "Factura no encontrada";
        }

        bill.setDate(billDto.getDate());
        bill.setTotal(billDto.getTotal());

        repo.save(bill);
        return "Factura actualizada correctamente";
    }

    public Bill dtoToEntity(BillDto billDto){
        return new Bill(
            billDto.getId(),
            billDto.getDate(),
            billDto.getTotal()
        );
    }

    public Bill entityToDto(Bill bill){
        return new Bill(
            bill.getId(),
            bill.getDate(),
            bill.getTotal()
        );
    }

    @Override
    public List<Bill> filterByDate(Date date){
        return repo.filterByDate(date);
    }

    @Override
    public String save(BillDto b){
        Bill bill = dtoToEntity(b);
        repo.save(bill);
        return "Factura guardada correctamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}
