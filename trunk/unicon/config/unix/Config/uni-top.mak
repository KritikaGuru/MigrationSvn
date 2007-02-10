include ../Makedefs

all :
	cd iyacc; $(MAKE)
	cd unicon; $(MAKE)
	cd lib; $(MAKE)
	cd ivib; $(MAKE)
	cd gui; $(MAKE)
	cd gui/ivib; $(MAKE)
	cd xml; $(MAKE)
	cd parser; $(MAKE)
	cd unidep; $(MAKE)
	cd util; $(MAKE)
	cd unidoc; $(MAKE)
	cd ide; $(MAKE)

clean Clean:
	cd iyacc; $(MAKE) Clean
	cd unicon; $(MAKE) Clean
	cd ivib; $(MAKE) Clean
	cd lib; $(MAKE) clean
	cd gui; $(MAKE) clean
	cd gui/ivib; $(MAKE) clean
	cd xml; $(MAKE) clean
	cd parser; $(MAKE) clean
	cd unidep; $(MAKE) clean
	cd util; $(MAKE) clean
	cd unidoc; $(MAKE) clean
	cd ide; $(MAKE) clean
