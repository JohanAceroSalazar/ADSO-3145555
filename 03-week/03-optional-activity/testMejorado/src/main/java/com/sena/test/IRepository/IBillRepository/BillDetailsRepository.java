package com.sena.test.IRepository.IBillRepository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import com.sena.test.Entity.Bill.BillDetails;

@Repository
public interface BillDetailsRepository extends JpaRepository<BillDetails, Integer>{

    @Query(""
			+ "SELECT "
			+ "b "
			+ "FROM "
			+ "bill_details b "
			+ "WHERE "
			+ "b.quantity = ?1"
			)
	public List<BillDetails>filterByQuantity(int quantity);
}