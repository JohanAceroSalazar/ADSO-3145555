package com.sena.test.Imple.BillService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.Dto.BillDto.BillDetailsDto;
import com.sena.test.Entity.Bill.BillDetails;
import com.sena.test.IRepository.IBillRepository.BillDetailsRepository;
import com.sena.test.IService.IBillService.IBillDetailsService;

@Service
public class BillDetailsServiceImple implements IBillDetailsService{

    @Autowired
    private BillDetailsRepository repo;

    @Override
    public List<BillDetails>findAll(){
        return repo.findAll();
    }

    @Override
    public BillDetails findById(int id){
        return repo.findById(id).orElse(null);
    }

    @Override
    public String update(int id, BillDetailsDto billDetailsDto){
        BillDetails billDetails = repo.findById(id).orElse(null);

        if(billDetails == null){
            return "Detalle de factura no encontrada";
        }

        billDetails.setQuantity(billDetailsDto.getQuantity());
        billDetails.setPrice(billDetailsDto.getPrice());

        repo.save(billDetails);
        return "Detalle de factura actualizada correctamente";
    }

    public BillDetails dtoToEntity(BillDetailsDto billDetailsDto){
        return new BillDetails(
            billDetailsDto.getId(),
            billDetailsDto.getQuantity(),
            billDetailsDto.getPrice()
        );
    }

    public BillDetails entityToDto(BillDetails billDetails){
        return new BillDetails(
            billDetails.getId(),
            billDetails.getQuantity(),
            billDetails.getPrice()
        );
    }

    @Override
    public List<BillDetails> filterByQuantity(int quantity){
        return repo.filterByQuantity(quantity);
    }

    @Override
    public String save(BillDetailsDto b){
        BillDetails billDetails = dtoToEntity(b);
        repo.save(billDetails);
        return "Detalle de Factura guardada correctamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}