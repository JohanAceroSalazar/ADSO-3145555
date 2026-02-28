package com.sena.test.Controller.BillController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.sena.test.Dto.BillDto.BillDetailsDto;
import com.sena.test.Entity.Bill.BillDetails;
import com.sena.test.IService.IBillService.IBillDetailsService;

@RestController
@RequestMapping("/detail")
public class BillDetailController {

    @Autowired
    private IBillDetailsService service;

    @GetMapping("")
    public ResponseEntity<Object>findAll(){
        return new ResponseEntity<Object>
        (service.findAll(),HttpStatus.OK);
    }

    @PostMapping("/id")
    public ResponseEntity<Object>save(
        @RequestBody BillDetailsDto d){
            service.save(d);
            return new ResponseEntity<Object>
            ("Se guardo exitosamente",HttpStatus.OK);
        }

    @GetMapping("{id}")
    public ResponseEntity<Object>findById(
        @PathVariable int id){
            BillDetails billDetails = service.findById(id);
            return new ResponseEntity<Object>
            (billDetails,HttpStatus.OK);
        }

    @PutMapping("/{id}")
    public ResponseEntity<Object> update(
        @PathVariable int id,
        @RequestBody BillDetailsDto billDetailsDto){

        return new ResponseEntity<>(
            service.update(id, billDetailsDto),
            HttpStatus.OK);
        }

    @GetMapping("filterByBillDetails/{BillDetails}")
    public ResponseEntity<Object>filterByQuantity(
        @PathVariable int quantity){
            List<BillDetails> billDetails = service.filterByQuantity(quantity);
            return new ResponseEntity<Object>
            (billDetails,HttpStatus.OK);
        }

    @DeleteMapping("{id}")
    public ResponseEntity<Object> delete(
        @PathVariable int id){
            service.delete(id);
            return new ResponseEntity<Object>
            ("Se elimino correctamente",HttpStatus.OK);
        }
}