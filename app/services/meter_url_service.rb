Chatgpt I have done a blunder
class Disco < ApplicationRecord
  has_many :regions, dependent: :destroy
  has_many :divisions, through: :regions
  has_many :subdivisions, through: :divisions
  has_many :meters, through: :subdivisions
end
class Region < ApplicationRecord
    belongs_to :disco
    has_many :divisions, dependent: :destroy
    has_many :subdivisions, through: :divisions
    has_many :meters, through: :subdivisions
  end
  class Division < ApplicationRecord
    belongs_to :region
    has_many :subdivisions, dependent: :destroy
    has_many :meters, through: :subdivisions
  end
class Subdivision < ApplicationRecord
    belongs_to :division
    has_many :meters, dependent: :destroy
end
class Meter < ApplicationRecord
  belongs_to :subdivision
  belongs_to :user, optional: true
  has_one_attached :image
  paginates_per 20
  validates  :REF_NO, presence: true
  # validates :NEW_METER_NUMBER, presence: true, uniqueness: true
  validates :REF_NO, presence: true, uniqueness: true

  has_one :inspection, dependent: :destroy
 def index
      
      discos = Rails.cache.fetch("all_discos", expires_in: 12.hours) do
        Disco.includes(regions: { divisions: { subdivisions: :meters } }).all
      end
      render json: discos, include: { 
        regions: { 
          include: { 
            divisions: {
              include: {
                subdivisions: {
                  include: {
                    meters: {
                      except: [:created_at, :updated_at, :subdivision_id]
                    }
                  },
                  except: [:created_at, :updated_at, :division_id]
                }
              },
              except: [:created_at, :updated_at, :region_id]
            }
          },
          except: [:created_at, :updated_at, :disco_id]
        }
      }
  end
import React, { useState, useEffect } from "react";

import "./index.css";
import axiosInstance from "../utils/Axios";
import MeterModal from "./meterModal/MeterModal";

import RightColumn from "./RightColumn.js";
import TableView from "./TableView.js";
import LeftColumn from "./LeftColumn.js";

const Index = () => {
  const [metreModal, setMetreModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState([]);
  const [selectedItemId, setSelectedItemId] = useState(null);
  const [data, setDiscosData] = useState([]);
  const [displayTree, setDisplayTree] = useState(true);
  const [loading, setLoading] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [highlightedItem, setHighlightedItem] = useState({
    name: "",
    type: "all",
    id: "",
  });
  const fetchCurrentUser = () => {
    axiosInstance
      .get("/v1/users/current")
      .then((response) => {
        setCurrentUser(response.data); // Corrected the parenthesis here
        console.log(response.data);
      }) // Ensure this parenthesis closes the then block
      .catch((error) => console.error("Error fetching current user:", error));
  };

  useEffect(() => {
    fetchCurrentUser();
    const fetchData = async () => {
      setLoading(true);
      try {
        const response = await axiosInstance.get("/v1/discos");
        setDiscosData(response.data);
        console.log(response.data)
        const allMeters = response.data.flatMap((disco) =>
          disco.regions.flatMap((region) =>
            region.divisions.flatMap((division) =>
              division.subdivisions.flatMap((subdivision) => subdivision.meters)
            )
          )
        );
        setSelectedItem(allMeters);
        console.log("All Meters:", allMeters);
      } catch (error) {
        console.error("Error fetching data:", error);
      }
      setLoading(false);
    };

    fetchData();
  }, []);

  const handleRegionClick = (item) => {
    const regionMeters = item.divisions.flatMap((division) =>
      division.subdivisions.flatMap((subdivision) => subdivision.meters)
    );
    console.log(regionMeters);

    setSelectedItem(regionMeters);
  };

  const handleItemClick = (item) => {
    setSelectedItem(item.meters);
  };

  const handleDivisionClick = (item) => {
    const divisionMeters = item.subdivisions.flatMap(
      (subdivision) => subdivision.meters
    );
    setSelectedItem(divisionMeters);
  };

  const handleAllData = (item) => {
    setSelectedItem(item);
  };

  const handleDiscosClick = (disco) => {
    console.log(disco);

    const discoMeters = disco.regions.flatMap((region) =>
      region.divisions.flatMap((division) =>
        division.subdivisions.flatMap((subdivision) => subdivision.meters)
      )
    );
    setSelectedItem(discoMeters);
  };

  function updateData(){
    const fetchData = async () => {
      try {
        const response = await axiosInstance.get("/v1/discos");
        setDiscosData(response.data);
  
        let filteredMeters = [];
        if (highlightedItem.type === 'disco') {
          const selectedDisco = response.data.find(disco => disco.id === highlightedItem.id);
          filteredMeters = selectedDisco.regions.flatMap(region =>
            region.divisions.flatMap(division =>
              division.subdivisions.flatMap(subdivision => subdivision.meters)
            )
          );
        }
        else if (highlightedItem.type === 'region') {
          const region = response.data.flatMap(disco => disco.regions)
                                       .find(region => region.id === highlightedItem.id);
          filteredMeters = region.divisions.flatMap(division =>
            division.subdivisions.flatMap(subdivision => subdivision.meters)
          );
        }
        else if (highlightedItem.type === 'division') {
          const division = response.data.flatMap(disco => disco.regions.flatMap(region => region.divisions))
                                         .find(division => division.id === highlightedItem.id);
          filteredMeters = division.subdivisions.flatMap(subdivision => subdivision.meters);
        }
        else if (highlightedItem.type === 'subdivision') {
          const subdivision = response.data.flatMap(disco => disco.regions.flatMap(region => region.divisions.flatMap(division => division.subdivisions)))
                                            .find(subdivision => subdivision.id === highlightedItem.id);
          filteredMeters = subdivision.meters;
        } else {
          // If no specific type is highlighted, default to showing all meters
          filteredMeters = response.data.flatMap(disco =>
            disco.regions.flatMap(region =>
              region.divisions.flatMap(division =>
                division.subdivisions.flatMap(subdivision => subdivision.meters)
              )
            )
          );
        }
  
        setSelectedItem(filteredMeters);
        console.log("Filtered Meters:", filteredMeters); // Log the final filteredMeters array
      } catch (error) {
        console.error("Error fetching data:", error);
      }
    };
  
    fetchData();
  }
  console.log(highlightedItem);
  if (loading) {
    return <div className="Loader">Loading...</div>;
  }
  return (
    <div style={{ display: "flex", height: "auto", minHeight: "100vh" }}>
      <div style={{ flex: 0.3, width: "100%" }}>
        <LeftColumn
          data={data}
          setSelectedItem={setSelectedItemId}
          setHighlightedItem={setHighlightedItem}
          selectedItemId={selectedItemId}
          onDiscosClick={handleDiscosClick}
          onDivisionClick={handleDivisionClick}
          onRegionClick={handleRegionClick}
          onItemClick={handleItemClick}
          onAllClick={handleAllData}
        />
      </div>
      <div style={{ flex: 1.7, width: "70%" }}>
        <div
          style={{
            display: "flex",
            flexDirection: "row",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          {highlightedItem.type !== "subdivision" && (
            <div style={{ display: "flex", flexDirection: "row" }}>
              {displayTree ? (
                <button
                  onClick={() => setDisplayTree(false)}
                  className="viewToggleBtn"
                  aria-label="Switch to Table View"
                >
                  Table View
                </button>
              ) : (
                <button
                  onClick={() => setDisplayTree(true)}
                  className="viewToggleBtn"
                  aria-label="Switch to Tree View"
                >
                  Tree View
                </button>
              )}
            </div>
          )}
        </div>
        {metreModal && (
          <MeterModal
            data={data}
            isOpen={metreModal}
            setIsOpen={setMetreModal}
          />
        )}
        {
          // Check if currentUser is not null before rendering RightColumn or TableView
          currentUser && highlightedItem.type === "subdivision" ? (
            <RightColumn
              selectedItem={selectedItem}
              item={highlightedItem}
              updateData={updateData}
              currentUserRole={currentUser.role} // Now safely accessed
            />
          ) : currentUser && displayTree ? (
            <RightColumn
              selectedItem={selectedItem}
              item={highlightedItem}
              updateData={updateData}
              currentUserRole={currentUser.role} // Now safely accessed
            />
          ) : currentUser ? (
            <TableView
              data={data}
              item={highlightedItem}
              updateData={updateData}
              currentUserRole={currentUser.role}

            />
          ) : (
            <div>Loading user data...</div> // Placeholder for loading state
          )
        }
      </div>
    </div>
  );
};

export default Index;
import React, { useState } from 'react';
import './LeftColumn.css';

// Utility functions for handling item toggles
const toggleItem = (list, setList, id) => {
  setList(list.includes(id) ? list.filter(item => item !== id) : [...list, id]);
};

const LeftColumn = ({ data, onItemClick, onDiscosClick, onDivisionClick, onRegionClick, setSelectedItem, setHighlightedItem, selectedItemId,onAllClick }) => {
  const [expandedItems, setExpandedItems] = useState([]);
  const [expandedDivisions, setExpandedDivisions] = useState([]);
  const [expandedRegions, setExpandedRegions] = useState([]);

  const handleSetSelectedItem = (id, type, name) => {
    setSelectedItem(${type}-${id});
    setHighlightedItem({ name, type,id });
  };

  const renderTreeItem = item => (
    <div key={item.id} className="tree-item">
      <div className={tree-item-header ${selectedItemId === disco-${item.id} ? "highlighted" : ""}}
           onClick={() => {
             onDiscosClick(item);
             toggleItem(expandedItems, setExpandedItems, item.id);
             handleSetSelectedItem(item.id, 'disco', item.name);
           }}>
        {item.regions.length > 0 ? (expandedItems.includes(item.id) ? "▼" : "►") : ""} {item.name}
      </div>
      {expandedItems.includes(item.id) && item.regions.map(renderRegionItem)}
    </div>
  );
  const renderAllOption = () => (
    <div className={tree-item-header ${selectedItemId === 'all' ? "highlighted" : ""}}
         onClick={() => {
          onAllClick(data.flatMap(disco =>
             disco.regions.flatMap(region =>
               region.divisions.flatMap(division =>
                 division.subdivisions.flatMap(subdivision => subdivision.meters)
               )
             )
           ));
           setSelectedItem('all');
           setHighlightedItem({ name: 'All', type: 'all' });
         }}>
      All
    </div>
  );

  const renderRegionItem = region => (
    <div key={region.id} className="tree-sub-item">
      <div className={tree-sub-item-header ${selectedItemId === region-${region.id} ? "highlighted" : ""}}
           onClick={() => {
             onRegionClick(region);
             toggleItem(expandedRegions, setExpandedRegions, region.id);
             handleSetSelectedItem(region.id, 'region', region.name);
           }}>
        {region.divisions.length > 0 ? (expandedRegions.includes(region.id) ? "▼" : "►") : ""} {region.name}
      </div>
      {expandedRegions.includes(region.id) && region.divisions.map(renderDivisionItem)}
    </div>
  );

  const renderDivisionItem = division => (
    <div key={division.id} className="tree-sub-sub-item">
      <div className={tree-sub-sub-item-header ${selectedItemId === division-${division.id} ? "highlighted" : ""}}
           onClick={() => {
             onDivisionClick(division);
             toggleItem(expandedDivisions, setExpandedDivisions, division.id);
             handleSetSelectedItem(division.id, 'division', division.name);
           }}>
        {division.subdivisions.length > 0 ? (expandedDivisions.includes(division.id) ? "▼" : "►") : ""} {division.name}
      </div>
      {expandedDivisions.includes(division.id) && division.subdivisions.map(subdivision => (
        <div key={subdivision.id} className="tree-sub-sub-sub-item">
          <div className={tree-sub-sub-sub-item-header ${selectedItemId === subdivision-${subdivision.id} ? "highlighted" : ""}}
               onClick={() => {
                 onItemClick(subdivision);
                 handleSetSelectedItem(subdivision.id, 'subdivision', subdivision.name);
               }}>
            {subdivision.name}
          </div>
        </div>
      ))}
    </div>
  );

  if (!data.length) return <div>No data available.</div>;

  return (
    <div className="left-column">
      {renderAllOption()}
      {data.map(renderTreeItem)}
    </div>
  );
};

export default LeftColumn;
import React, { useEffect, useState } from "react";
import { useDropzone } from "react-dropzone";
import Pagination from "./Pagination";
import MeterModal from "./meterModal/MeterModal";
import "./index.css";
import axiosInstance from "../utils/Axios";
import "./RightColumn.css";
import { FaEdit, FaTrash } from "react-icons/fa";
import EditMeter from "./EditMeter";

const RightColumn = ({ selectedItem, updateData, item, currentUserRole }) => {
  console.log(item.type);
  const [search, setSearch] = useState({ meterNo: "", refNo: "" });
  const [connectionTypeFilter, setConnectionTypeFilter] = useState("");
  const [telcoFilter, setTelcoFilter] = useState("");
  const [meterTypeFilter, setMeterTypeFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(15);
  const [metreModal, setMetreModal] = useState(false);
  const [importModal, setImportModal] = useState(false);
  const [selectedMeters, setSelectedMeters] = useState([]);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [selectedMeter, setSelectedMeter] = useState(null);
  // Assuming 'currentUserRole' is passed as a prop or from context/global state
  const canEdit = currentUserRole === "Field Supervisor" || currentUserRole === "Admin";
  const canImport = currentUserRole === "Admin";

  console.log(currentUserRole);
  const [file, setFile] = useState(null);
  //  console.log(currentUserRole)
  useEffect(() => {
    // Reset filters when the selected item changes
    setTelcoFilter("");
    setMeterTypeFilter("");
    setStatusFilter("");
    setCurrentPage(1);
  }, [selectedItem]);

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const filteredItems = selectedItem
    ? selectedItem.filter((meter) => {
        return (
          (telcoFilter
            ? meter.TELCO && meter.TELCO.includes(telcoFilter)
            : true) &&
          (connectionTypeFilter
            ? meter.CONNECTION_TYPE === connectionTypeFilter
            : true) &&
          (statusFilter ? meter.METER_STATUS === statusFilter : true) &&
          (search.meterNo
            ? meter.NEW_METER_NUMBER.includes(search.meterNo)
            : true) &&
          (search.refNo ? meter.REF_NO.includes(search.refNo) : true)
        );
      })
    : [];

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredItems.slice(indexOfFirstItem, indexOfLastItem);

  const { getRootProps, getInputProps } = useDropzone({
    onDrop: (acceptedFiles) => {
      setFile(acceptedFiles[0]);
    },
    accept: "text/csv",
  });

  const handleImportMeters = () => {
    if (!file) {
      alert("Please select a CSV file to import!");
      return;
    }
  
    const formData = new FormData();
    formData.append("file", file);
    formData.append('meter[subdivision_id]', item.id);
  
    axiosInstance
      .post("/v1/meters/import", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      })
      .then((response) => {
        // Assuming the server sends back a JSON response with successes and errors array
        if (response.data.errors && response.data.errors.length > 0) {
          // Display a detailed error report
          const errorMessages = response.data.errors.map(err => ${err.ref_no}: ${err.error}).join("\n");
          alert(Import completed with errors:\n${errorMessages});
        } else {
          alert("All meters imported successfully!");
        }
        
        updateData();
        setImportModal(false); // Close the modal
        setFile(null); // Reset file
      })
      .catch((error) => {
        console.error("Import failed:", error);
        alert("Failed to import meters. Please check the console for more details.");
      });
  };
  

  const toggleImportModal = () => {
    setFile(null); // Reset file on opening/closing modal
    setImportModal(!importModal);
  };

  const handleExportMeters = () => {
    console.log("Exporting meters...");
    const meterIds = filteredItems.map((item) => item.id);
    console.log("Filtered Items:", filteredItems); // Log to confirm items

    axiosInstance({
      url: "/v1/meters/export",
      method: "POST",
      responseType: "blob",
      data: { meter_ids: meterIds },
    })
      .then((response) => {
        const fileURL = window.URL.createObjectURL(new Blob([response.data]));
        const fileLink = document.createElement("a");
        fileLink.href = fileURL;
        fileLink.setAttribute("download", "exported_meters.csv"); // Set file name
        document.body.appendChild(fileLink);
        fileLink.click();
        fileLink.remove(); // Clean up after download
      })
      .catch((error) => {
        console.error("Error exporting meters:", error);
      });
  };
  const handleMeterSelection = (id) => {
    setSelectedMeters((prev) =>
      prev.includes(id)
        ? prev.filter((meterId) => meterId !== id)
        : [...prev, id]
    );
  };

  const handleSelectAll = (e) => {
    if (e.target.checked) {
      setSelectedMeters(currentItems.map((item) => item.id));
    } else {
      setSelectedMeters([]);
    }
  };

  const handleDeleteSelected = async () => {
    if (selectedMeters.length === 0) {
      alert("No meters selected for deletion.");
      return;
    }
    try {
      const response = await axiosInstance.delete("/v1/meters/bulk_delete", {
        data: { meter_ids: selectedMeters }, // Make sure to send meter IDs
      });
      alert("Selected meters deleted successfully!");
      setSelectedMeters([]); // Clear selections
      updateData();

      // Optionally, fetch the updated list or modify state to remove deleted items
    } catch (error) {
      console.error("Failed to delete meters:", error);
      alert("Failed to delete selected meters: " + error.response.data.error);
    }
  };
  const handleEdit = (meter) => {
    setSelectedMeter(meter);
    setEditModalOpen(true);
  };

  return (
    <>
      {canEdit && (
        <EditMeter
          isOpen={editModalOpen}
          setIsOpen={setEditModalOpen}
          meterId={selectedMeter ? selectedMeter.id : null}
          updateData={updateData} 
        />
      )}
      {metreModal && (
        <MeterModal isOpen={metreModal} setIsOpen={setMetreModal} updateData={updateData} item={item} />
      )}
      {importModal && (
        <div className="modal">
          <div className="modal-content">
            <span className="close" onClick={toggleImportModal}>
              &times;
            </span>
            <h3 className="modal-title">Import Meters</h3>
            <div {...getRootProps({ className: "dropzone" })}>
              <input {...getInputProps()} />
              <p>Drag 'n' drop a CSV file here, or click to select a file</p>
            </div>
            <button className="import-button" onClick={handleImportMeters}>
              Import Meters
            </button>
          </div>
        </div>
      )}
      <div className="right-column-container">
        {item.type === "subdivision" && canEdit && (
          <button className="addMetre" onClick={() => setMetreModal(true)}>
            Add Meter
          </button>
        )}

        {canEdit && (
          <button
            className="delete-meters-button"
            onClick={handleDeleteSelected}
            disabled={selectedMeters.length === 0}
          >
            Delete Selected Meters
          </button>
        )}
        <div className="filters">
          <input
            type="text"
            placeholder="Search by Meter No."
            value={search.meterNo}
            onChange={(e) => setSearch({ ...search, meterNo: e.target.value })}
          />
          <input
            type="text"
            placeholder="Search by Ref. No."
            value={search.refNo}
            onChange={(e) => setSearch({ ...search, refNo: e.target.value })}
          />
          <select
            value={connectionTypeFilter}
            onChange={(e) => setConnectionTypeFilter(e.target.value)}
          >
            <option value="">All Connection Types</option>
            <option value="Industrial">Industrial</option>
            <option value="Street">Street</option>
            <option value="Commercial">Commercial</option>
            <option value="Residential">Residential</option>
          </select>
          <select
            value={telcoFilter}
            onChange={(e) => setTelcoFilter(e.target.value)}
          >
            <option value="">All Telcos</option>
            <option value="Jazz">Jazz</option>
            <option value="Warid">Warid</option>
            <option value="Zong">Zong</option>
            <option value="Ufone">Ufone</option>
            <option value="Telenor">Telenor</option>
          </select>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="">All Statuses</option>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
          </select>
        </div>
        <div className="meter-management-buttons">
          {item.type === "subdivision" && (
            <button
              className="button import-button"
              onClick={toggleImportModal}
            >
              Import Meters
            </button>
          )}
          <button className="button export-button" onClick={handleExportMeters}>
            Export Meters
          </button>
        </div>
        {currentItems.length > 0 ? (
          <table className="meter-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>NEW_METER_NUMBER</th>
                <th>REF_NO</th>
                <th>METER_STATUS</th>
                <th>OLD_METER_NUMBER</th>
                <th>OLD_METER_READING</th>
                <th>NEW_METER_READING</th>
                <th>CONNECTION_TYPE</th>
                <th>BILL_MONTH</th>
                <th>LONGITUDE</th>
                <th>LATITUDE</th>
                <th>METER_TYPE</th>
                <th>KWH_MF</th>
                <th>SAN_LOAD</th>
                <th>CONSUMER_NAME</th>
                <th>CONSUMER_ADDRESS</th>
                <th>QC_CHECK</th>
                <th>APPLICATION_NO</th>
                <th>GREEN_METER</th>
                <th>TELCO</th>
                <th>SIM_NO</th>
                <th>SIGNAL_STRENGTH</th>
                <th>PICTURE_UPLOAD</th>
                <th>METR_REPLACE_DATE_TIME</th>
                <th>NO_OF_RESET_OLD_METER</th>
                <th>NO_OF_RESET_NEW_METER</th>
                <th>KWH_T1</th>
                <th>KWH_T2</th>
                <th>KWH_TOTAL</th>
                <th>KVARH_T1</th>
                <th>KVARH_T2</th>
                <th>KVARH_TOTAL</th>
                <th>MDI_T1</th>
                <th>MDI_T2</th>
                <th>MDI_TOTAL</th>
                <th>CUMULATIVE_MDI_T1</th>
                <th>CUMULATIVE_MDI_T2</th>
                <th>CUMULATIVE_MDI_Total</th>
                {canEdit && <th>Edit</th>}
                {canEdit && <th>Delete</th>}
              </tr>
            </thead>
            <tbody>
              {currentItems.map((meter) => (
                <tr key={meter.id}>
                  <td>{meter.id}</td>
                  <td>{meter.NEW_METER_NUMBER}</td>
                  <td>{meter.REF_NO}</td>
                  <td>{meter.METER_STATUS}</td>
                  <td>{meter.OLD_METER_NUMBER}</td>
                  <td>{meter.OLD_METER_READING}</td>
                  <td>{meter.NEW_METER_READING}</td>
                  <td>{meter.CONNECTION_TYPE}</td>
                  <td>{meter.BILL_MONTH}</td>
                  <td>{meter.LONGITUDE}</td>
                  <td>{meter.LATITUDE}</td>
                  <td>{meter.METER_TYPE}</td>
                  <td>{meter.KWH_MF}</td>
                  <td>{meter.SAN_LOAD}</td>
                  <td>{meter.CONSUMER_NAME}</td>
                  <td>{meter.CONSUMER_ADDRESS}</td>
                  <td>{meter.QC_CHECK ? "Yes" : "No"}</td>
                  <td>{meter.APPLICATION_NO}</td>
                  <td>{meter.GREEN_METER}</td>
                  <td>{meter.TELCO}</td>
                  <td>{meter.SIM_NO}</td>
                  <td>{meter.SIGNAL_STRENGTH}</td>
                  <td>
                    {meter.PICTURE_UPLOAD && (
                      <a href={meter.PICTURE_UPLOAD} target="_blank">
                        View Image
                      </a>
                    )}
                  </td>
                  <td>{meter.METR_REPLACE_DATE_TIME}</td>
                  <td>{meter.NO_OF_RESET_OLD_METER}</td>
                  <td>{meter.NO_OF_RESET_NEW_METER}</td>
                  <td>{meter.KWH_T1}</td>
                  <td>{meter.KWH_T2}</td>
                  <td>{meter.KWH_TOTAL}</td>
                  <td>{meter.KVARH_T1}</td>
                  <td>{meter.KVARH_T2}</td>
                  <td>{meter.KVARH_TOTAL}</td>
                  <td>{meter.MDI_T1}</td>
                  <td>{meter.MDI_T2}</td>
                  <td>{meter.MDI_TOTAL}</td>
                  <td>{meter.CUMULATIVE_MDI_T1}</td>
                  <td>{meter.CUMULATIVE_MDI_T2}</td>
                  <td>{meter.CUMULATIVE_MDI_Total}</td>
                  {canEdit && (
                    <>
                      <td>
                        <FaEdit
                          className="edit-icon"
                          onClick={() => handleEdit(meter)}
                        />
                      </td>
                      <td>
                        <input
                          type="checkbox"
                          checked={selectedMeters.includes(meter.id)}
                          onChange={() => handleMeterSelection(meter.id)}
                        />
                      </td>
                    </>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p>No meters found based on filters.</p>
        )}

        <Pagination
          currentPage={currentPage}
          itemsPerPage={itemsPerPage}
          totalItems={filteredItems.length}
          onPageChange={handlePageChange}
        />
      </div>
    </>
  );
};

export default RightColumn;
import React, { useEffect, useState } from "react";
import axiosInstance from "../utils/Axios";
import ConfirmationModal from "../utils/ConfirmationModal";
import "./index.css";
import AddItemModal from "./AddItemModal";

const TableView = ({ data, item, updateData, currentUserRole }) => {
  const [allItems, setAllItems] = useState([]); // This will hold the IDs of selected discos
  const [selectedDiscoItems, setSelectedDiscoItems] = useState([]);
  const [selectedRegionItems, setSelectedRegionItems] = useState([]);
  const [selectedDivisionItems, setSelectedDivisionItems] = useState([]);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [confirmationMessage, setConfirmationMessage] = useState("");
  const [showAddModal, setShowAddModal] = useState(false);
  const canEdit = currentUserRole === "Field Supervisor" || currentUserRole === "Admin";
  const canImport = currentUserRole === "Admin";
  useEffect(() => {
    // Clear selections when item changes
    setAllItems([]);
    setSelectedDiscoItems([]);
    setSelectedRegionItems([]);
    setSelectedDivisionItems([]);
  }, [item]);
  const handleAddNewClick = () => {
    setShowAddModal(true);
  };

  const handleModalClose = () => {
    setShowAddModal(false);
  };

  const handleAddItemSubmit = async (event) => {
    event.preventDefault();
    const { name } = event.target.elements;
    try {
      await axiosInstance.post(/v1/discos/add_${item.type}, {
        name: name.value,
      });
      updateData(); // refresh the list
      handleModalClose();
      console.log("Addition successful");
    } catch (error) {
      console.error("Error adding item:", error);
    }
  };
  const handleCheckboxChange = (id, type) => {
    let setter = null;
    switch (type) {
      case "all":
        setter = setAllItems;
        break;
      case "disco":
        setter = setSelectedDiscoItems;
        break;
      case "region":
        setter = setSelectedRegionItems;
        break;
      case "division":
        setter = setSelectedDivisionItems;
        break;
      default:
        return;
    }
    setter((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const handleDelete = () => {
    const { type } = item;
    let confirmationMsg = "";
    switch (type) {
      case "all":
        confirmationMsg = Are you sure you want to delete the selected Discos and all their associated entities?;
        break;
      case "disco":
        confirmationMsg = Are you sure you want to delete the selected regions and all their associated entities from ${item.name}?;
        break;
      case "region":
        confirmationMsg = Are you sure you want to delete the selected divisions and all their associated subdivisions from ${item.name}?;
        break;
      case "division":
        confirmationMsg = Are you sure you want to delete the selected subdivisions from ${item.name}?;
        break;
      default:
        return;
    }
    setConfirmationMessage(confirmationMsg);
    setShowConfirmation(true);
  };

  const confirmDelete = async () => {
    const { type } = item;
    let url = "";
    let idsToDelete = [];

    switch (type) {
      case "all":
        url = "/v1/discos/delete_discos";
        idsToDelete = allItems;
        break;
      case "disco":
        url = "/v1/discos/delete_regions";
        idsToDelete = selectedDiscoItems;
        break;
      case "region":
        url = "/v1/discos/delete_divisions";
        idsToDelete = selectedRegionItems;
        break;
      case "division":
        url = "/v1/discos/delete_subdivisions";
        idsToDelete = selectedDivisionItems;
        break;
      default:
        setShowConfirmation(false);
        return;
    }

    try {
      await axiosInstance.delete(url, { data: { ids: idsToDelete } });
      updateData();
      console.log("Deletion successful");
    } catch (error) {
      console.error("Error deleting items:", error);
    }
    setShowConfirmation(false);
  };

  const cancelDelete = () => setShowConfirmation(false);

  const renderContent = () => {
    let content = [];
    switch (item.type) {
      case "all":
        content = data.map((disco) => ({ id: disco.id, name: disco.name }));
        break;
      case "disco":
        const disco = data.find((d) => d.name === item.name);
        content = disco?.regions || [];
        break;
      case "region":
        data.forEach((disco) => {
          const region = disco.regions.find((r) => r.name === item.name);
          if (region) content = region.divisions;
        });
        break;
      case "division":
        data.forEach((disco) => {
          disco.regions.forEach((region) => {
            const division = region.divisions.find((d) => d.name === item.name);
            if (division) content = division.subdivisions;
          });
        });
        break;
      default:
        content = [];
    }
    return content.map((c) => (
      <tr key={c.id}>
        <td>{c.id}</td>
        <td>{c.name}</td>
        {canEdit && (
          <>
        <td className="checkbox-cell">
          <input
            type="checkbox"
            checked={
              item.type === "all"
                ? allItems.includes(c.id)
                : item.type === "disco"
                ? selectedDiscoItems.includes(c.id)
                : item.type === "region"
                ? selectedRegionItems.includes(c.id)
                : selectedDivisionItems.includes(c.id)
            }
            onChange={() => handleCheckboxChange(c.id, item.type)}
          />
        </td>
        </>
         )}
      </tr>
    ));
  };

  return (
    <div className="table-view-container">
      {showConfirmation && (
        <ConfirmationModal
          message={confirmationMessage}
          onConfirm={confirmDelete}
          onCancel={cancelDelete}
        />
      )}
      <div className="table-view-buttons">
        <AddItemModal
          isOpen={showAddModal}
          onClose={handleModalClose}
          onSubmit={handleAddItemSubmit}
          itemType={
            item.type === "all"
              ? "Disco"
              : item.type === "disco"
              ? "Region"
              : item.type === "region"
              ? "Division"
              : "Subdivision"
          }
          itemId={item.id}
          parentName={item.name}
          updateData={updateData}
          
        />
          {canEdit && (
            <>
        <button
          className="table-view-button"
          onClick={handleAddNewClick}
          >
          Add
        </button>
        <button className="table-view-button" onClick={handleDelete}>
          Delete
        </button>
        </>
         )}
      </div>
      <table className="table-view">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            {canEdit && (
            <th>Delete</th>
          )}
          </tr>
        </thead>
        <tbody>{renderContent()}</tbody>
      </table>
    </div>
  );
};

export default TableView;
import React from 'react';
import './index.css'
const Pagination = ({ currentPage, itemsPerPage, totalItems, onPageChange }) => {
  return (
    <div className="pagination-container">
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        className="pagination-button"
      >
        Previous
      </button>
      <span className="pagination-text">
        Page {currentPage} of {Math.ceil(totalItems / itemsPerPage)}
      </span>
      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={totalItems <= currentPage * itemsPerPage}
        className="pagination-button"
      >
        Next
      </button>
    </div>
  );
};

export default Pagination;
I have loaded All the data in one go. When the Meter size is large like 1 lac meter it becomes very slow. I want the Ui like this but want to handle pagination only for meters at the backend
def index
      
      # discos = Rails.cache.fetch("all_discos", expires_in: 12.hours) do
      #   Disco.includes(regions: { divisions: { subdivisions: :meters } }).all
      # end
      discos = Disco.includes(regions: { divisions: { subdivisions: :meters } }).all
      render json: discos, include: { 
        regions: { 
          include: { 
            divisions: {
              include: {
                subdivisions: {
                  except: [:created_at, :updated_at, :division_id]
                }
              },
              except: [:created_at, :updated_at, :region_id]
            }
          },
          except: [:created_at, :updated_at, :disco_id]
        }
      }
  end
Now I want to fetch all the discos, regions, division and sub division. ANd when I select some specific ID od disoc, regions, division or sub division it should load it all
def index
  discos = Disco.includes(regions: { divisions: :subdivisions }).all
  render json: discos, include: {
    regions: {
      include: {
        divisions: {
          include: {
            subdivisions: {
              except: [:created_at, :updated_at, :division_id]
            }
          },
          except: [:created_at, :updated_at, :region_id]
        }
      },
      except: [:created_at, :updated_at, :disco_id]
    }
  }
end

def meters
  subdivision_id = params[:subdivision_id]
  division_id = params[:division_id]
  region_id = params[:region_id]
  disco_id = params[:disco_id]

  meters = if subdivision_id
             Subdivision.find(subdivision_id).meters
           elsif division_id
             Division.find(division_id).meters
           elsif region_id
             Region.find(region_id).meters
           elsif disco_id
             Disco.find(disco_id).meters
           else
             Meter.all
           end

  meters = meters.page(params[:page]).per(params[:per_page])

  render json: meters, except: [:created_at, :updated_at, :subdivision_id]
end