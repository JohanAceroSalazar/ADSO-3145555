package com.sena.test.IRepository.IBillRepository;

import java.sql.Date;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import com.sena.test.Entity.Bill.Bill;

@Repository
public interface BillRepository extends JpaRepository<Bill, Integer>{

    @Query(""
			+ "SELECT "
			+ "b "
			+ "FROM "
			+ "bill b "
			+ "WHERE "
			+ "b.date = ?1"
			)
	public List<Bill>filterByDate(Date date);
}