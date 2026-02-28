package com.sena.test.Controller.BillController;

import java.sql.Date;
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
import com.sena.test.Dto.BillDto.BillDto;
import com.sena.test.Entity.Bill.Bill;
import com.sena.test.IService.IBillService.IBillService;

@RestController
@RequestMapping("/bill")
public class BillController {

    @Autowired
    private IBillService service;

    @GetMapping("")
    public ResponseEntity<Object>findAll(){
        return new ResponseEntity<Object>
        (service.findAll(),HttpStatus.OK);
    }

    @PostMapping("/id")
    public ResponseEntity<Object>save(
        @RequestBody BillDto b){
            service.save(b);
            return new ResponseEntity<Object>
            ("Se guardo exitosamente",HttpStatus.OK);
        }

    @GetMapping("{id}")
    public ResponseEntity<Object>findById(
        @PathVariable int id){
            Bill bill = service.findById(id);
            return new ResponseEntity<Object>
            (bill,HttpStatus.OK);
        }

    @PutMapping("/{id}")
    public ResponseEntity<Object> update(
        @PathVariable int id,
        @RequestBody BillDto billDto){

        return new ResponseEntity<>(
            service.update(id, billDto),
            HttpStatus.OK);
        }

    @GetMapping("filterByBill/{Bill}")
    public ResponseEntity<Object>filterByDate(
        @PathVariable Date date){
            List<Bill> bill = service.filterByDate(date);
            return new ResponseEntity<Object>
            (bill,HttpStatus.OK);
        }

    @DeleteMapping("{id}")
    public ResponseEntity<Object> delete(
        @PathVariable int id){
            service.delete(id);
            return new ResponseEntity<Object>
            ("Se elimino correctamente",HttpStatus.OK);
        }
}